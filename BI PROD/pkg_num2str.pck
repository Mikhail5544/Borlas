CREATE OR REPLACE PACKAGE pkg_num2str AS
  ----========================================================================----
  -- Сумма прописью. 
  -- Входные значения: par_num: 123456789012.12 - не более 15 знаков в длину, 
  -- вместе с разделителем и дробной частью. Дробная часть может 
  -- отсутствовать.
  -- par_fund_brief - валюта: RUR, USD или EUR
  FUNCTION Num_To_Str
  (
    par_num        NUMBER
   ,par_fund_brief VARCHAR2
  ) RETURN VARCHAR2;
  ----========================================================================----
END PKG_NUM2STR;
/
CREATE OR REPLACE PACKAGE BODY pkg_num2str AS
  ----========================================================================----
  -- Сумма прописью. 
  -- Входные значения: par_num: 123456789012.12 - не более 15 знаков в длину, 
  -- вместе с разделителем и дробной частью. Дробная часть может 
  -- отсутствовать.
  -- par_fund_brief - валюта: RUR, USD или EUR
  FUNCTION Num_To_Str
  (
    par_num        NUMBER
   ,par_fund_brief VARCHAR2
  ) RETURN VARCHAR2 IS
    v_stmon VARCHAR2(255) := ''; -- результат (монтирование строки)
    v_st    VARCHAR2(15); -- вспомогательная переменная
    v_char3 VARCHAR2(3); -- три знака
    v_tr1   VARCHAR2(1); -- сотни
    v_tr2   VARCHAR2(1); -- десятки
    v_tr3   VARCHAR2(1); -- единицы
    v_kop1  VARCHAR2(1); -- десятки копеек
    v_kop2  VARCHAR2(1); -- единицы копеек
  BEGIN
    -- {конвертация из флоат в строку}
    v_st := SUBSTR((TO_CHAR(ABS(par_num), '999999999990D00')), 2, 15);
    FOR i IN 1 .. 5
    LOOP
      -- выделяем три цифры
      v_char3 := SUBSTR(v_st, 1, 3);
      v_st    := SUBSTR(v_st, 4, (LENGTH(v_st) - 3));
      -- первая цифра из трёх
      v_tr1 := SUBSTR(v_char3, 1, 1);
      -- вторая цифра из трёх
      v_tr2 := SUBSTR(v_char3, 2, 1);
      -- третья цифра из трёх
      v_tr3 := SUBSTR(v_char3, 3, 1);
      -- Обработка целой части числа
      IF i <> 5
      THEN
        -- обработка первой цифры
        IF v_tr1 = '1'
        THEN
          v_stmon := v_stmon || 'сто ';
        ELSIF v_tr1 = '2'
        THEN
          v_stmon := v_stmon || 'двести ';
        ELSIF v_tr1 = '3'
        THEN
          v_stmon := v_stmon || 'триста ';
        ELSIF v_tr1 = '4'
        THEN
          v_stmon := v_stmon || 'четыреста ';
        ELSIF v_tr1 = '5'
        THEN
          v_stmon := v_stmon || 'пятьсот ';
        ELSIF v_tr1 = '6'
        THEN
          v_stmon := v_stmon || 'шестьсот ';
        ELSIF v_tr1 = '7'
        THEN
          v_stmon := v_stmon || 'семьсот ';
        ELSIF v_tr1 = '8'
        THEN
          v_stmon := v_stmon || 'восемьсот ';
        ELSIF v_tr1 = '9'
        THEN
          v_stmon := v_stmon || 'девятьсот ';
        END IF;
        -- обработка 2 цифры
        IF v_tr2 = '1'
        THEN
          IF v_tr3 = '0'
          THEN
            v_stmon := v_stmon || 'десять ';
          ELSIF v_tr3 = '1'
          THEN
            v_stmon := v_stmon || 'одиннадцать ';
          ELSIF v_tr3 = '2'
          THEN
            v_stmon := v_stmon || 'двенадцать ';
          ELSIF v_tr3 = '3'
          THEN
            v_stmon := v_stmon || 'тpинадцать ';
          ELSIF v_tr3 = '4'
          THEN
            v_stmon := v_stmon || 'четыpнадцать ';
          ELSIF v_tr3 = '5'
          THEN
            v_stmon := v_stmon || 'пятнадцать ';
          ELSIF v_tr3 = '6'
          THEN
            v_stmon := v_stmon || 'шестнадцать ';
          ELSIF v_tr3 = '7'
          THEN
            v_stmon := v_stmon || 'семнадцать ';
          ELSIF v_tr3 = '8'
          THEN
            v_stmon := v_stmon || 'восемнадцать ';
          ELSIF v_tr3 = '9'
          THEN
            v_stmon := v_stmon || 'девятнадцать ';
          END IF;
        ELSIF v_tr2 = '2'
        THEN
          v_stmon := v_stmon || 'двадцать ';
        ELSIF v_tr2 = '3'
        THEN
          v_stmon := v_stmon || 'тpидцать ';
        ELSIF v_tr2 = '4'
        THEN
          v_stmon := v_stmon || 'соpок ';
        ELSIF v_tr2 = '5'
        THEN
          v_stmon := v_stmon || 'пятьдесят ';
        ELSIF v_tr2 = '6'
        THEN
          v_stmon := v_stmon || 'шестьдесят ';
        ELSIF v_tr2 = '7'
        THEN
          v_stmon := v_stmon || 'семьдесят ';
        ELSIF v_tr2 = '8'
        THEN
          v_stmon := v_stmon || 'восемьдесят ';
        ELSIF v_tr2 = '9'
        THEN
          v_stmon := v_stmon || 'девяносто ';
        END IF;
        -- обработка 3 цифры
        IF v_tr2 != '1'
        THEN
          IF v_tr3 = '1'
             AND i != 3
          THEN
            v_stmon := v_stmon || 'один ';
          ELSIF v_tr3 = '1'
                AND i = 3
          THEN
            v_stmon := v_stmon || 'одна ';
          ELSIF v_tr3 = '2'
                AND i != 3
          THEN
            v_stmon := v_stmon || 'два ';
          ELSIF v_tr3 = '2'
                AND i = 3
          THEN
            v_stmon := v_stmon || 'две ';
          ELSIF v_tr3 = '3'
          THEN
            v_stmon := v_stmon || 'тpи ';
          ELSIF v_tr3 = '4'
          THEN
            v_stmon := v_stmon || 'четыpе ';
          ELSIF v_tr3 = '5'
          THEN
            v_stmon := v_stmon || 'пять ';
          ELSIF v_tr3 = '6'
          THEN
            v_stmon := v_stmon || 'шесть ';
          ELSIF v_tr3 = '7'
          THEN
            v_stmon := v_stmon || 'семь ';
          ELSIF v_tr3 = '8'
          THEN
            v_stmon := v_stmon || 'восемь ';
          ELSIF v_tr3 = '9'
          THEN
            v_stmon := v_stmon || 'девять ';
          END IF;
        END IF;
        -- Обработка миллиардов
        IF i = 1
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr1 = '0')
                AND (v_tr2 = '0')
                AND (v_tr3 = '0')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || 'миллиаpд ';
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || 'миллиаpда ';
          ELSE
            v_stmon := v_stmon || 'миллиаpдов ';
          END IF;
        END IF;
        -- Обработка миллионов
        IF i = 2
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr1 = '0')
                AND (v_tr2 = '0')
                AND (v_tr3 = '0')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || 'миллион ';
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || 'миллиона ';
          ELSE
            v_stmon := v_stmon || 'миллионов ';
          END IF;
        END IF;
        -- Обработка тысяч
        IF i = 3
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr1 = '0')
                AND (v_tr2 = '0')
                AND (v_tr3 = '0')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 <> '1')
          THEN
            v_stmon := v_stmon || 'тысяча ';
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 <> '1')
          THEN
            v_stmon := v_stmon || 'тысячи ';
          ELSE
            v_stmon := v_stmon || 'тысяч ';
          END IF;
        END IF;
        -- Обработка сотен
        IF i = 4
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 != '1')
          THEN
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'pубль ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || 'доллар ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || 'евро ';
            END IF;
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 != '1')
          THEN
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'pубля ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || 'доллара ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || 'евро ';
            END IF;
          ELSIF (v_tr1 = ' ')
                AND (v_tr2 = ' ')
                AND (v_tr3 = '0')
          THEN
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'ноль pублей ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || 'ноль долларов ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || 'ноль евро ';
            END IF;
          ELSE
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'pублей ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || 'долларов ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || 'евро ';
            END IF;
          END IF;
        END IF;
      ELSIF i = 5
      THEN
        -- выделение десятков копеек
        v_kop1 := SUBSTR(v_char3, 2, 1);
        -- выделение единиц копеек
        v_kop2 := SUBSTR(v_char3, 3, 1);
        -- {добавление копеек к результирующей строке}
        v_stmon := v_stmon || v_kop1 || v_kop2 || ' ';
        IF (v_kop2 = '1')
           AND (v_kop1 != '1')
        THEN
          IF par_fund_brief = 'RUR'
          THEN
            v_stmon := v_stmon || 'копейка';
          ELSIF par_fund_brief = 'USD'
          THEN
            v_stmon := v_stmon || 'цент';
          ELSIF par_fund_brief = 'EUR'
          THEN
            v_stmon := v_stmon || 'евроцент';
          END IF;
        ELSIF (v_kop2 = '2' OR v_kop2 = '3' OR v_kop2 = '4')
              AND (v_kop1 != '1')
        THEN
          IF par_fund_brief = 'RUR'
          THEN
            v_stmon := v_stmon || 'копейки';
          ELSIF par_fund_brief = 'USD'
          THEN
            v_stmon := v_stmon || 'цента';
          ELSIF par_fund_brief = 'EUR'
          THEN
            v_stmon := v_stmon || 'евроцента';
          END IF;
        ELSE
          IF par_fund_brief = 'RUR'
          THEN
            v_stmon := v_stmon || 'копеек';
          ELSIF par_fund_brief = 'USD'
          THEN
            v_stmon := v_stmon || 'центов';
          ELSIF par_fund_brief = 'EUR'
          THEN
            v_stmon := v_stmon || 'евроцентов';
          END IF;
        END IF;
      END IF;
    END LOOP;
    -- преобразование первого симовла строки в прописную букву
    v_stmon := UPPER(SUBSTR(v_stmon, 1, 1)) || SUBSTR(v_stmon, 2, (LENGTH(v_stmon) - 1));
    RETURN(v_stmon);
  END Num_To_Str;
  ----========================================================================----
  /*
  FUNCTION get_sum_str_2 (source IN NUMBER)
  RETURN varchar2 is result VARCHAR2(300);
  BEGIN
  -- k - копейки
    if source < 1
       then
          result := 'ноль '||
             ltrim(
                   to_char(
                           source,'9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99'
                          )
                  ) || 'k';
       else
          result := ltrim(
                          to_char
                          (
                           source,'9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99'
                          )
                         ) || 'k';
    end if;
  
  -- t - тысячи; m - милионы; M - миллиарды;
    result := replace( result, ',,,,,,', 'eM');
    result := replace( result, ',,,,,', 'em');
    result := replace( result, ',,,,', 'et');
  -- e - единицы; d - десятки; c - сотни;
    result := replace( result, ',,,', 'e');
    result := replace( result, ',,', 'd');
    result := replace( result, ',', 'c');
  -- Удаление незначащих нулей
    result := replace( result, '0c0d0et', '');
    result := replace( result, '0c0d0em', '');
    result := replace( result, '0c0d0eM', '');
  
  -- Обработка сотен
    result := replace( result, '0c', '');
    result := replace( result, '1c', 'сто ');
    result := replace( result, '2c', 'двести ');
    result := replace( result, '3c', 'триста ');
    result := replace( result, '4c', 'четыреста ');
    result := replace( result, '5c', 'пятьсот ');
    result := replace( result, '6c', 'шестьсот ');
    result := replace( result, '7c', 'семьсот ');
    result := replace( result, '8c', 'восемьсот ');
    result := replace( result, '9c', 'девятьсот ');
  
  -- Обработка десятков
    result := replace( result, '1d0e', 'десять ');
    result := replace( result, '1d1e', 'одиннадцать ');
    result := replace( result, '1d2e', 'двенадцать ');
    result := replace( result, '1d3e', 'тринадцать ');
    result := replace( result, '1d4e', 'четырнадцать ');
    result := replace( result, '1d5e', 'пятнадцать ');
    result := replace( result, '1d6e', 'шестнадцать ');
    result := replace( result, '1d7e', 'семьнадцать ');
    result := replace( result, '1d8e', 'восемнадцать ');
    result := replace( result, '1d9e', 'девятнадцать ');
    result := replace( result, '0d', '');
    result := replace( result, '2d', 'двадцать ');
    result := replace( result, '3d', 'тридцать ');
    result := replace( result, '4d', 'сорок ');
    result := replace( result, '5d', 'пятьдесят ');
    result := replace( result, '6d', 'шестьдесят ');
    result := replace( result, '7d', 'семьдесят ');
    result := replace( result, '8d', 'восемьдесят ');
    result := replace( result, '9d', 'девяносто ');
  
  -- Обработка единиц
    result := replace( result, '0e', '');
    result := replace( result, '5e', 'пять ');
    result := replace( result, '6e', 'шесть ');
    result := replace( result, '7e', 'семь ');
    result := replace( result, '8e', 'восемь ');
    result := replace( result, '9e', 'девять ');
  --
    result := replace( result, '1e.', 'один рубль ');
    result := replace( result, '2e.', 'два рубля ');
    result := replace( result, '3e.', 'три рубля ');
    result := replace( result, '4e.', 'четыре рубля ');
    result := replace( result, '1et', 'одна тысяча ');
    result := replace( result, '2et', 'две тысячи ');
    result := replace( result, '3et', 'три тысячи ');
    result := replace( result, '4et', 'четыре тысячи ');
    result := replace( result, '1em', 'один миллион ');
    result := replace( result, '2em', 'два миллиона ');
    result := replace( result, '3em', 'три миллиона ');
    result := replace( result, '4em', 'четыре миллиона ');
    result := replace( result, '1eM', 'один милиард ');
    result := replace( result, '2eM', 'два милиарда ');
    result := replace( result, '3eM', 'три милиарда ');
    result := replace( result, '4eM', 'четыре милиарда ');
  
  -- Обработка копеек
    result := replace( result, '11k', '11 копеек');
    result := replace( result, '12k', '12 копеек');
    result := replace( result, '13k', '13 копеек');
    result := replace( result, '14k', '14 копеек');
    result := replace( result, '1k', '1 копейка');
    result := replace( result, '2k', '2 копейки');
    result := replace( result, '3k', '3 копейки');
    result := replace( result, '4k', '4 копейки');
  
  -- Обработка названий групп
    result := replace( result, '.', 'рублей ');
    result := replace( result, 't', 'тысяч ');
    result := replace( result, 'm', 'миллионов ');
    result := replace( result, 'M', 'милиардов ');
    result := replace( result, 'k', ' копеек');
  --
    RETURN(result);
  END get_sum_str_2; 
  */
  ----========================================================================----

  /* СОЗДАНИЕ ФУНКЦИИ ПЕРЕВОДА ДАТЫ В СТРОКУ В РОДИТЕЛЬНОМ ПАДЕЖЕ */
  FUNCTION daterusr(d DATE) RETURN VARCHAR2 IS
    /* entry - date
    exit - date in russian text roditelnij padej */
    ds    VARCHAR2(100);
    DAY   CHAR(2);
    MONTH CHAR(2);
    YEAR  CHAR(4);
  BEGIN
    IF d < TO_DATE('01-01-1990', 'DD-MM-YYYY')
    THEN
      RETURN 'Разрешен диапазон дат: 01.01.1990 - 31.12.2020. Задано: ' || TO_CHAR(d, 'YYYY');
    ELSIF d > TO_DATE('31-12-2020', 'DD-MM-YYYY')
    THEN
      RETURN 'Разрешен диапазон дат: 01.01.1990 - 31.12.2020. Задано: ' || TO_CHAR(d, 'YYYY');
    ELSE
      DAY   := TO_CHAR(d, 'DD');
      MONTH := TO_CHAR(d, 'MM');
      YEAR  := TO_CHAR(d, 'YYYY');
    
      IF DAY = '01'
      THEN
        ds := 'Первого ';
      ELSIF DAY = '02'
      THEN
        ds := 'Второго ';
      ELSIF DAY = '03'
      THEN
        ds := 'Третьего ';
      ELSIF DAY = '04'
      THEN
        ds := 'Четвертого ';
      ELSIF DAY = '05'
      THEN
        ds := 'Пятого ';
      ELSIF DAY = '06'
      THEN
        ds := 'Шестого ';
      ELSIF DAY = '07'
      THEN
        ds := 'Седьмого ';
      ELSIF DAY = '08'
      THEN
        ds := 'Восьмого ';
      ELSIF DAY = '09'
      THEN
        ds := 'Девятого ';
      ELSIF DAY = '10'
      THEN
        ds := 'Десятого ';
      ELSIF DAY = '11'
      THEN
        ds := 'Одиннадцатого ';
      ELSIF DAY = '12'
      THEN
        ds := 'Двенадцатого ';
      ELSIF DAY = '13'
      THEN
        ds := 'Тринадцатого ';
      ELSIF DAY = '14'
      THEN
        ds := 'Четырнадцатого ';
      ELSIF DAY = '15'
      THEN
        ds := 'Пятнадцатого ';
      ELSIF DAY = '16'
      THEN
        ds := 'Шестнадцатого ';
      ELSIF DAY = '17'
      THEN
        ds := 'Семнадцатого ';
      ELSIF DAY = '18'
      THEN
        ds := 'Восемнадцатого ';
      ELSIF DAY = '19'
      THEN
        ds := 'Девятнадцатого ';
      ELSIF DAY = '20'
      THEN
        ds := 'Двадцатого ';
      ELSIF DAY = '21'
      THEN
        ds := 'Двадцать первого ';
      ELSIF DAY = '22'
      THEN
        ds := 'Двадцать второго ';
      ELSIF DAY = '23'
      THEN
        ds := 'Двадцать третьго ';
      ELSIF DAY = '24'
      THEN
        ds := 'Двадцать четвертого ';
      ELSIF DAY = '25'
      THEN
        ds := 'Двадцать пятого ';
      ELSIF DAY = '26'
      THEN
        ds := 'Двадцать шестого ';
      ELSIF DAY = '27'
      THEN
        ds := 'Двадцать седьмого ';
      ELSIF DAY = '28'
      THEN
        ds := 'Двадцать восьмого ';
      ELSIF DAY = '29'
      THEN
        ds := 'Двадцать девятого ';
      ELSIF DAY = '30'
      THEN
        ds := 'Тридцатого ';
      ELSIF DAY = '31'
      THEN
        ds := 'Тридцать первого ';
      END IF;
    
      IF MONTH = '01'
      THEN
        ds := ds || 'января ';
      ELSIF MONTH = '02'
      THEN
        ds := ds || 'февраля ';
      ELSIF MONTH = '03'
      THEN
        ds := ds || 'марта ';
      ELSIF MONTH = '04'
      THEN
        ds := ds || 'апреля ';
      ELSIF MONTH = '05'
      THEN
        ds := ds || 'мая ';
      ELSIF MONTH = '06'
      THEN
        ds := ds || 'июня ';
      ELSIF MONTH = '07'
      THEN
        ds := ds || 'июля ';
      ELSIF MONTH = '08'
      THEN
        ds := ds || 'августа ';
      ELSIF MONTH = '09'
      THEN
        ds := ds || 'сентября ';
      ELSIF MONTH = '10'
      THEN
        ds := ds || 'октября ';
      ELSIF MONTH = '11'
      THEN
        ds := ds || 'ноября ';
      ELSIF MONTH = '12'
      THEN
        ds := ds || 'декабря ';
      END IF;
    
      IF YEAR = '1990'
      THEN
        ds := ds || 'одна тысяча девятьсот девяностого';
      ELSIF YEAR = '1991'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто первого';
      ELSIF YEAR = '1992'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто второго';
      ELSIF YEAR = '1993'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто третьего';
      ELSIF YEAR = '1994'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто четвертого';
      ELSIF YEAR = '1995'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто пятого';
      ELSIF YEAR = '1996'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто шестого';
      ELSIF YEAR = '1997'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто седьмого';
      ELSIF YEAR = '1998'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто восьмого';
      ELSIF YEAR = '1999'
      THEN
        ds := ds || 'одна тысяча девятьсот девяносто девятого';
      ELSIF YEAR = '2000'
      THEN
        ds := ds || 'двухтысячного';
      ELSIF YEAR = '2001'
      THEN
        ds := ds || 'две тысячи первого';
      ELSIF YEAR = '2002'
      THEN
        ds := ds || 'две тысячи второго';
      ELSIF YEAR = '2003'
      THEN
        ds := ds || 'две тысячи третьего';
      ELSIF YEAR = '2004'
      THEN
        ds := ds || 'две тысячи четвертого';
      ELSIF YEAR = '2005'
      THEN
        ds := ds || 'две тысячи пятого';
      ELSIF YEAR = '2006'
      THEN
        ds := ds || 'две тысячи шестого';
      ELSIF YEAR = '2007'
      THEN
        ds := ds || 'две тысячи седьмого';
      ELSIF YEAR = '2008'
      THEN
        ds := ds || 'две тысячи восьмого';
      ELSIF YEAR = '2009'
      THEN
        ds := ds || 'две тысячи девятого';
      ELSIF YEAR = '2010'
      THEN
        ds := ds || 'две тысячи десятого';
      ELSIF YEAR = '2011'
      THEN
        ds := ds || 'две тысячи одиннадцатого';
      ELSIF YEAR = '2012'
      THEN
        ds := ds || 'две тысячи двенадцатого';
      ELSIF YEAR = '2013'
      THEN
        ds := ds || 'две тысячи тринадцатого';
      ELSIF YEAR = '2014'
      THEN
        ds := ds || 'две тысячи четырнадцатого';
      ELSIF YEAR = '2015'
      THEN
        ds := ds || 'две тысячи пятнадцатого';
      ELSIF YEAR = '2016'
      THEN
        ds := ds || 'две тысячи шестнадцатого';
      ELSIF YEAR = '2017'
      THEN
        ds := ds || 'две тысячи семнадцатого';
      ELSIF YEAR = '2018'
      THEN
        ds := ds || 'две тысячи восемнадцатого';
      ELSIF YEAR = '2019'
      THEN
        ds := ds || 'две тысячи девятнадцатого';
      ELSIF YEAR = '2020'
      THEN
        ds := ds || 'две тысячи двадцатого';
      END IF;
      ds := ds || ' года';
      RETURN ds;
    END IF;
  END daterusr;
  ----========================================================================----
END PKG_NUM2STR;
/

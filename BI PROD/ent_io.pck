CREATE OR REPLACE PACKAGE ENT_IO AS

  /*
  * Работа по выгрузки и загрузки объектов сущности
  * @author Процветов Е.
  * @version 1
  * @headcom
  */

  /**
  * Функция возвращает сокращение Сущности по ID
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @return Сокращение сущности
  */
  FUNCTION brief_by_id(p_ent_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает ID Сущности по BRIEF
  * @author Процветов Е.
  * @param P_BRIEF Сокращение Сущности
  * @return ID сущности
  */
  FUNCTION id_by_brief(p_brief VARCHAR2) RETURN NUMBER;

  /**
  * Процедура вывода ошибки
  * @author Процветов Е.
  * @param P_ERR_TXT Текст ошибки
  */
  PROCEDURE set_err_txt(p_err_txt IN VARCHAR2);

  /**
  * Функция возвращает текст ошибки
  * @author Процветов Е.
  * @return Текст ошибки
  */
  FUNCTION get_err_txt RETURN VARCHAR2;

  /**
  * Процедура открытия xml-файла
  * @author Процветов Е.
  * @param P_XML_ID Идентификатор XML-файла
  */
  PROCEDURE open_xml(p_xml_id OUT NUMBER);

  /**
  * Процедура закрытия xml-файла
  * @author Процветов Е.
  * @param P_XML_ID Идентификатор XML-файла
  */
  PROCEDURE close_xml(p_xml_id IN NUMBER);

  /**
  * Процедура удаления xml-файла
  * @author Процветов Е.
  * @param P_XML_ID Идентификатор XML-файла
  */
  PROCEDURE delete_xml(p_xml_id IN NUMBER);

  /**
  * Процедура формирования xml-файла
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @param P_OBJ_ID ID Выгружаемого объекта
  * @param P_XML_ID Идентификатор файла
  * @param P_WHERE ID Дополнительное условие на выгрузку объектов сущности
  * @param P_RES Результирующая строка
  */
  PROCEDURE append_to_xml
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_xml_id IN NUMBER
   ,p_where  IN VARCHAR2
   ,p_res    OUT NUMBER
  );

  /**
  * Процедура формирования xml-файла
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @param P_OBJ_ID ID Выгружаемого объекта
  * @param P_XML_ID Идентификатор файла
  * @param P_WHERE ID Дополнительное условие на выгрузку объектов сущности
  * @param P_RES Результирующая строка
  */
  /*PROCEDURE append_to_xml(p_ent_brief  IN  VARCHAR2,
  p_obj_id     IN  NUMBER,
  p_xml_id     IN  NUMBER,
  p_where      IN  VARCHAR2,
  p_res        OUT NUMBER);*/
  /**
  * Функция возвращает наименование первичного ключа по ID Сущности
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @return Наименование первичного ключа для сущности
  */
  FUNCTION primkey_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает наименование представления сущности по ID Сущности
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @return Наименование представления сущности
  */
  FUNCTION view_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Процедура инициализации глобальных параметров
  * @author Процветов Е.
  * @param P_XML_ID ID экземпляра XML-файла
  */
  PROCEDURE init_gparams(p_xml_id IN NUMBER);

  /**
  * Процедура формирования "attr" тега
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @param P_OBJ_ID ID Выгружаемого объекта
  * @param P_LEV Уровень вложенности
  */
  PROCEDURE cre_attr_tag
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_lev    IN NUMBER
  );

  /**
  * Процедура формирования "key" тега
  * @author Процветов Е.
  * @param P_ENT_ID ID Сущности
  * @param P_OBJ_ID ID Выгружаемого объекта
  * @param P_LEV Уровень вложенности
  */
  PROCEDURE cre_key_tag
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_lev    IN NUMBER
  );

  /**
  * Процедура вставки строки будущего xml-файла в таблицу
  * @author Процветов Е.
  * @param P_TEXT Строка XML
  */
  PROCEDURE insert_txt(p_text IN VARCHAR2);

  /**
  * Функция загрузки данных в БД из xml-файла
  * @author Процветов Е.
  * @param dir дирректория с XML-файлом
  * @param inpfile XML-файл
  * @param errfile Файл с отчётом по загрузке XML-файла
  * @return 1-файл загружен / 0-незагружен
  */
  FUNCTION load_xml
  (
    dir     VARCHAR2 DEFAULT NULL
   ,inpfile VARCHAR2 DEFAULT NULL
   ,errfile VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Функция выгрузки Программы по ID
  * @author Процветов Е.
  * @param p_product_id ID Продукта
  * @param p_exp_prod_coef_type_by_id Флаг выгрузки Функций
  * @param p_exp_questionnaire_type Флаг выгрузки Анкет
  * @param p_tmp_xml_id ID XML-файла в таблице
  * @return Идентификатор XML-файла в таблице
  */
  FUNCTION exp_prod_line
  (
    p_product_line_id          NUMBER
   ,p_exp_prod_coef_type_by_id NUMBER DEFAULT 1
   ,p_exp_questionnaire_type   NUMBER DEFAULT 1
   ,p_tmp_xml_id               NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Функция выгрузки объекта сущности Продукт по ID
  * @author Процветов Е.
  * @param p_product_id ID Продукта
  * @param p_exp_prod_coef_type_by_id Флаг выгрузки Функций
  * @param p_exp_questionnaire_type Флаг выгрузки Анкет
  * @return Идентификатор XML-файла в таблице
  */
  FUNCTION exp_product_by_id
  (
    p_product_id               NUMBER
   ,p_exp_prod_coef_type_by_id NUMBER DEFAULT 1
   ,p_exp_questionnaire_type   NUMBER DEFAULT 1
  ) RETURN NUMBER;

  /**
  * Функция выгрузки Функций по её ID
  * @author Процветов Е.
  * @param p_product_id ID Функции
  * @param p_tmp_xml_id ID XML-файла в таблице
  * @return Идентификатор XML-файла в таблице
  */
  FUNCTION exp_prod_coef_type_by_id
  (
    p_prod_coef_type_id NUMBER
   ,p_tmp_xml_id        NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Функция выгрузки Анкеты по её ID
  * @author Процветов Е.
  * @param p_pquestionnaire_type_id ID Анкеты
  * @param p_tmp_xml_id ID XML-файла в таблице
  * @return Идентификатор XML-файла в таблице
  */
  FUNCTION exp_questionnaire_type_by_id
  (
    p_questionnaire_type_id NUMBER
   ,p_tmp_xml_id            NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Процедура выгрузки настроек Аттрибутов сущности
  * @author Процветов Е.
  * @param p_ent_id ID Сущности
  * @param p_exp_id ID XML-файла
  */
  PROCEDURE exp_ent_settings
  (
    p_ent_id IN NUMBER
   ,p_exp_id IN NUMBER
  );

  /**
  * Процедура выгрузки настроек Аттрибутов сущности
  * @author Процветов Е.
  * @param p_ent_brief Код Сущности
  * @param p_exp_id ID XML-файла
  */
  PROCEDURE exp_ent_settings
  (
    p_ent_brief IN VARCHAR2
   ,p_exp_id    IN NUMBER
  );

  /**
  * Процедура выгрузки настроек Аттрибутов списка сущностей
  * @author Процветов Е.
  * @param p_entы_brief Список Сущностей
  * @param p_exp_id ID XML-файла
  */
  PROCEDURE exp_list_ent_settings
  (
    p_ents_brief IN VARCHAR2
   ,p_exp_id     IN NUMBER
  );

  /**
  * Функция загрузки метаданных и настроек аттрибутов сущности в БД из xml-файла
  * @author Процветов Е.
  * @param dir дирректория с XML-файлом
  * @param inpfile XML-файл
  * @param errfile Файл с отчётом по загрузке XML-файла
  * @return 1-файл загружен / 0-незагружен
  */
  FUNCTION load_ent_settings
  (
    dir     VARCHAR2
   ,inpfile VARCHAR2
   ,errfile VARCHAR2
  ) RETURN NUMBER;

  /**
  * Функция выгрузки метаданных и настроек аттрибутов сущностей для Продукта
  * @author Процветов Е.
  * @param p_tmp_xml_id ID XML-файла
  * @return ID XML-файла
  */
  FUNCTION exp_prod_ent_settings
  (
    p_tmp_xml_id                NUMBER DEFAULT NULL
   ,p_exp_prod_coef_typ_ent_set NUMBER DEFAULT 1
   ,p_quest_type_ent_set        NUMBER DEFAULT 1
  ) RETURN NUMBER;

  /**
  * Функция выгрузки метаданных и настроек аттрибутов сущностей для Функций
  * @author Процветов Е.
  * @param p_tmp_xml_id ID XML-файла
  * @return ID XML-файла
  */
  FUNCTION exp_prod_coef_typ_ent_settings(p_tmp_xml_id NUMBER DEFAULT NULL) RETURN NUMBER;

  /**
  * Функция выгрузки метаданных и настроек аттрибутов сущностей для Параметров
  * @author Процветов Е.
  * @param p_tmp_xml_id ID XML-файла
  * @return ID XML-файла
  */
  FUNCTION exp_app_param_ent_settings(p_tmp_xml_id NUMBER DEFAULT NULL) RETURN NUMBER;

  /**
  * Функция выгрузки метаданных и настроек аттрибутов сущностей для Анкет
  * @author Процветов Е.
  * @param p_tmp_xml_id ID XML-файла
  * @return ID XML-файла
  */
  FUNCTION exp_quest_type_ent_settings(p_tmp_xml_id NUMBER DEFAULT NULL) RETURN NUMBER;

  /**
  * Функция выгрузки Параметра прилжения по его ID
  * @author Процветов Е.
  * @param p_app_param_id ID Параметра
  * @param p_tmp_xml_id ID XML-файла в таблице
  * @return Идентификатор XML-файла в таблице
  */
  FUNCTION exp_app_param_by_id
  (
    p_app_param_id NUMBER
   ,p_tmp_xml_id   NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE init_clob;
  PROCEDURE add_clob(p_str VARCHAR2);

  /**
  * Функция проверки наличия записи в таблице
  * @author Процветов Е.
  * @param p_ent_id ID Сущности
  * @param p_obj_id ID Объекта
  * @return 1/0 - существует/не_существует
  */
  FUNCTION check_exist
  (
    p_ent_id NUMBER
   ,p_obj_id NUMBER
  ) RETURN NUMBER;

END ENT_IO;
/
CREATE OR REPLACE PACKAGE BODY ENT_IO AS
  xml_file CLOB; -- Здесь храним здоровенный xml-файл

  --запись для работы с аттрибутами сущности
  TYPE fields_name IS RECORD(
     attr_id    attr.ATTR_ID%TYPE
    ,brief      attr.BRIEF%TYPE
    ,col_name   attr.COL_NAME%TYPE
    ,KEY        attr.is_key%TYPE
    ,TYPE       attr_type.BRIEF%TYPE
    ,ref_ent_id attr.ref_ent_id%TYPE
    ,val        VARCHAR2(32000));

  --коллекция для работы с аттрибутами
  TYPE list_of_names IS TABLE OF fields_name INDEX BY BINARY_INTEGER;

  --Исключения
  EXCMANYREC EXCEPTION;
  PRAGMA EXCEPTION_INIT(EXCMANYREC, -20001);

  --номер записи в xml-файле
  G_ROW_ID     NUMBER := 0;
  G_TMP_XML_ID NUMBER;
  G_MAX_LEV    NUMBER := 10;

  --Глобальная переменная текста Ошибки загрузки/выгрузки
  G_ERR_TXT VARCHAR2(32000);

  /*******************************************************************************/
  FUNCTION check_exist
  (
    p_ent_id NUMBER
   ,p_obj_id NUMBER
  ) RETURN NUMBER IS
    v_id_name VARCHAR2(30);
    v_cnt     NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'select count(*) from ' || ent_io.BRIEF_BY_ID(p_ent_id) || ' where ' ||
                      ent_io.PRIMKEY_BY_ID(p_ent_id) || ' = ' || p_obj_id
      INTO v_cnt;
  
    IF v_cnt > 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  /*******************************************************************************/

  PROCEDURE set_err_txt(p_err_txt IN VARCHAR2) IS
  BEGIN
    G_ERR_TXT := p_err_txt;
    RAISE_APPLICATION_ERROR(-20000, p_err_txt);
  END;

  /*******************************************************************************/

  FUNCTION get_err_txt RETURN VARCHAR2 IS
  BEGIN
    RETURN G_ERR_TXT;
  END;

  /*******************************************************************************/

  FUNCTION primkey_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
    cur_ent_key VARCHAR2(30);
  BEGIN
    SELECT e.ID_NAME INTO cur_ent_key FROM entity e WHERE e.ENT_ID = p_ent_id;
  
    RETURN cur_ent_key;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      set_err_txt('В таблице ENTITY не найдена запись, соответствующая сущности ' ||
                  BRIEF_BY_ID(p_ent_id));
  END;

  /*******************************************************************************/

  FUNCTION brief_by_id(p_ent_id NUMBER) RETURN VARCHAR2 IS
    s VARCHAR2(30);
  BEGIN
    SELECT brief INTO s FROM entity WHERE ent_id = p_ent_id;
    RETURN s;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --set_err_txt('В таблице ENTITY не найдена запись, соответствующая сущности с ID='|| p_ent_id);
      RETURN NULL;
  END;

  /*******************************************************************************/

  FUNCTION id_by_brief(p_brief VARCHAR2) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT ent_id INTO num FROM entity WHERE brief = UPPER(p_brief);
    RETURN num;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --set_err_txt('В таблице ENTITY не найдена запись, соответствующая сущности с BRIEF='|| p_BRIEF);
      RETURN NULL;
  END;

  /*******************************************************************************/

  FUNCTION view_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
    cur_ent_key VARCHAR2(30);
    s           VARCHAR2(30);
  BEGIN
    s := 'VEN_' || BRIEF_BY_ID(p_ent_id);
    BEGIN
      EXECUTE IMMEDIATE 'select * from ' || s;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        set_err_txt('В базе не найдено представление ' || s || ' сущности ' || BRIEF_BY_ID(p_ent_id));
    END;
    RETURN s;
  END;

  /*******************************************************************************/

  PROCEDURE insert_txt(p_text IN VARCHAR2) IS
  BEGIN
    G_ROW_ID := G_ROW_ID + 1;
    --dbms_output.put_line(P_TEXT);
    INSERT INTO TMP_XML (TMP_XML_ID, ROW_ID, TEXT) VALUES (G_TMP_XML_ID, G_ROW_ID, P_TEXT);
    COMMIT;
  END;

  /*******************************************************************************/

  PROCEDURE open_xml(p_xml_id OUT NUMBER) IS
  BEGIN
    SELECT SQ_TMP_XML.NEXTVAL INTO G_TMP_XML_ID FROM dual;
    p_xml_id := G_TMP_XML_ID;
    G_ROW_ID := 0;
    insert_txt('<?xml version="1.0" encoding="windows-1251" ?> ');
    insert_txt('<export>');
  END;

  /*******************************************************************************/

  PROCEDURE close_xml(p_xml_id IN NUMBER) IS
  BEGIN
    init_gparams(p_xml_id);
    insert_txt('</export>');
  END;

  /*******************************************************************************/

  PROCEDURE delete_xml(p_xml_id IN NUMBER) IS
  BEGIN
    DELETE FROM TMP_XML t WHERE t.TMP_XML_ID = p_xml_id;
    COMMIT;
  END;

  /*******************************************************************************/

  PROCEDURE init_gparams(p_xml_id IN NUMBER) IS
  BEGIN
    G_TMP_XML_ID := p_xml_id;
    SELECT MAX(t.row_id) INTO G_ROW_ID FROM TMP_XML t WHERE t.TMP_XML_ID = p_xml_id;
  END;

  /*******************************************************************************/

  PROCEDURE append_to_xml
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_xml_id IN NUMBER
   ,p_where  IN VARCHAR2
   ,p_res    OUT NUMBER
  ) IS
    TYPE ref_cur IS REF CURSOR;
    cur    ref_cur;
    val_id NUMBER;
    whr    VARCHAR2(32000);
  BEGIN
    IF NVL(p_obj_id, 0) <> -555
    THEN
      IF (p_xml_id IS NOT NULL)
         AND (p_ent_id IS NOT NULL)
      THEN
        init_gparams(p_xml_id);
      
        IF (p_obj_id IS NULL)
        THEN
          -- dbms_output.put_line('Начало выгрузки всех объектов сущности '||ent.brief_by_id(p_ent_id));
          IF p_where IS NOT NULL
             AND LENGTH(p_where) > 0
          THEN
            whr := ' where ' || p_where;
          END IF;
          OPEN cur FOR 'select ' || PRIMKEY_BY_ID(p_ent_id) || ' from ' || VIEW_BY_ID(p_ent_id) || NVL(whr
                                                                                                      ,'');
          LOOP
            FETCH cur
              INTO val_id;
            EXIT WHEN cur%NOTFOUND;
            -- dbms_output.put_line('Объект сущности '||ent.brief_by_id(p_ent_id)||': '||val_id);
            cre_attr_tag(p_ent_id, val_id, 1);
          END LOOP;
          CLOSE cur;
          -- dbms_output.put_line('Конец выгрузки всех объектов сущности '||ent.brief_by_id(p_ent_id));
        ELSE
          cre_attr_tag(p_ent_id, p_obj_id, 1);
        END IF;
      
        p_res := G_TMP_XML_ID;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_res := NULL;
  END;

  /*******************************************************************************/

  /*PROCEDURE append_to_xml(p_ent_brief  IN  VARCHAR2,
                            p_obj_id     IN  NUMBER,
                            p_xml_id     IN  NUMBER,
                            p_where      IN  VARCHAR2,
                            p_res        OUT NUMBER) IS
    BEGIN
      append_to_xml(id_by_brief(upper(p_ent_brief)),p_obj_id,p_xml_id,p_where,p_res);
    END;
  */

  /*******************************************************************************/

  PROCEDURE cre_attr_tag
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_lev    IN NUMBER
  ) IS
    str          VARCHAR2(32000);
    tmp_str      VARCHAR2(32000);
    attr_table   list_of_names;
    val          VARCHAR2(32000);
    val_uro      NUMBER;
    is_reference BOOLEAN := TRUE;
    val_ref      NUMBER;
  BEGIN
    IF p_lev <= G_MAX_LEV
    THEN
      insert_txt(LPAD(' ', 3 * p_lev) || '<ent brief=''' || brief_by_id(p_ent_id) || '''>');
    
      --определяем набор аттрибутов для выгрузки в XML для текущей Сущности
      SELECT a.attr_id
            ,a.BRIEF
            ,a.COL_NAME
            ,a.IS_KEY     KEY
            ,AT.BRIEF     TYPE
            ,a.ref_ent_id
            ,NULL         BULK COLLECT
        INTO attr_table
        FROM attr a
        JOIN attr_type AT
          ON AT.ATTR_TYPE_ID = a.ATTR_TYPE_ID
       WHERE a.is_excl = 0
         AND a.ent_id IN (SELECT e.ent_id
                            FROM entity e
                           START WITH e.ent_id = p_ent_id
                          CONNECT BY e.ent_id = PRIOR e.parent_id);
    
      --дополняем REF_ENT_ID для сущности T_PROD_COEF данными из T_PROD_COEF_TYPE
      IF ent_io.BRIEF_BY_ID(p_ent_id) IN ('T_PROD_COEF')
      THEN
        FOR i IN attr_table.FIRST .. attr_table.LAST
        LOOP
          IF SUBSTR(attr_table(i).col_name, 1, 9) = 'CRITERIA_'
          THEN
            BEGIN
              EXECUTE IMMEDIATE 'select a.ATTRIBUT_ENT_ID' || ' from T_PROD_COEF pc' ||
                                ' join T_PROD_COEF_TYPE pct on pct.T_PROD_COEF_TYPE_ID = pc.T_PROD_COEF_TYPE_ID' ||
                                ' join T_ATTRIBUT a on a.T_ATTRIBUT_ID = pct.FACTOR_' ||
                                SUBSTR(attr_table(i).col_name, 10) || ' where pc.T_PROD_COEF_ID = ' ||
                                p_obj_id
                INTO val_ref;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                val_ref := NULL;
            END;
            attr_table(i).ref_ent_id := val_ref;
          END IF;
        END LOOP;
      END IF;
    
      --добавляем в XML аттрибуты для текущего объекта
      FOR i IN attr_table.FIRST .. attr_table.LAST
      LOOP
        --находим значение для текущего аттрибута
        --dbms_output.put_line(attr_table(i).col_name);
        BEGIN
          EXECUTE IMMEDIATE 'select ' || attr_table(i).col_name || ' from ' || view_by_id(p_ent_id) ||
                            ' where ' || primkey_by_id(p_ent_id) || '=' || p_obj_id
            INTO val;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            val := NULL;
        END;
      
        --строка в XML
        str := LPAD(' ', 3 * p_lev + 3) || '<attr brief=''' || attr_table(i).COL_NAME || '''';
      
        IF attr_table(i).KEY = 1
        THEN
          str := str || ' key=''Y''';
        ELSE
          str := str || ' key=''N''';
        END IF;
      
        --Проверка на заполненность поля URO_ID
        IF attr_table(i).TYPE = 'UR'
            AND SUBSTR(UPPER(attr_table(i).col_name), -6) = 'URE_ID'
        THEN
          BEGIN
            EXECUTE IMMEDIATE 'select ' || REPLACE(UPPER(attr_table(i).col_name), 'URE_ID', 'URO_ID') ||
                              '  from ' || brief_by_id(p_ent_id) || ' where ' ||
                              primkey_by_id(p_ent_id) || '=' || p_obj_id
              INTO val_uro;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              val_uro := NULL;
          END;
        
          IF val_uro IS NULL
          THEN
            attr_table(i).TYPE := 'RE';
          END IF;
        END IF;
      
        str := str || ' type=''' || attr_table(i).TYPE || '''';
      
        --проверяем наличие значения в справочнике для сущности T_PROD_COEF данными из T_PROD_COEF_TYPE
        IF ent_io.BRIEF_BY_ID(p_ent_id) IN ('T_PROD_COEF')
           AND SUBSTR(attr_table(i).col_name, 1, 9) = 'CRITERIA_'
        THEN
          IF attr_table(i).ref_ent_id IS NOT NULL
              AND val IS NOT NULL
              AND ent_io.check_exist(attr_table(i).ref_ent_id, val) = 1
          THEN
            is_reference := TRUE;
          ELSE
            is_reference := FALSE;
          END IF;
        ELSE
          is_reference := TRUE;
        END IF;
      
        /*  if val is null then val:='';
        end if;*/
      
        IF attr_table(i).TYPE IN ('R')
            AND val IS NOT NULL
            AND is_reference
        THEN
          IF attr_table(i).ref_ent_id IS NULL
              AND ent_io.BRIEF_BY_ID(p_ent_id) NOT IN ('T_PROD_COEF')
          THEN
            set_err_txt('Ошибка при выгрузке данных для сущности ' || brief_by_id(p_ent_id) ||
                        '. Для аттрибута-ссылки ' || attr_table(i).COL_NAME ||
                        ' не заполнено поле REF_ENT_ID' || CHR(10) ||
                        'Необходима корректировка настроек аттрибутов сущности (ATTR)');
          ELSE
            str := str || ' ref_ent=''' || brief_by_id(attr_table(i).ref_ent_id) || '''>';
            insert_txt(str);
            --формируем аттрибуты по "ключевым" тегам
            cre_key_tag(attr_table(i).ref_ent_id, TO_NUMBER(val), p_lev + 1);
            insert_txt(LPAD(' ', 3 * p_lev + 3) || '</attr>');
          END IF;
        ELSE
          IF val IS NULL
          THEN
            str := str || ' val=''''/>'; --||val||'''/>';
            insert_txt(str);
          ELSE
            --если есть аттрибут-ссылка на таблицу Сущностей
            IF attr_table(i).TYPE = 'RE'
            THEN
              str := str || '><![CDATA[' || BRIEF_BY_ID(val) || ']]>';
              insert_txt(str);
              insert_txt(LPAD(' ', 3 * p_lev + 3) || '</attr>');
            ELSE
              IF attr_table(i).TYPE = 'UR'
              THEN
                str := str || ' ref_ent=''' || brief_by_id(val) || '''>';
                insert_txt(str);
                --формируем аттрибуты по "ключевым" тегам
                EXECUTE IMMEDIATE 'select ' ||
                                  REPLACE(UPPER(attr_table(i).col_name), 'URE_ID', 'URO_ID') ||
                                  '  from ' || brief_by_id(p_ent_id) || ' where ' ||
                                  primkey_by_id(p_ent_id) || '=' || p_obj_id
                  INTO val_uro;
              
                cre_key_tag(val, val_uro, p_lev + 1);
                insert_txt(LPAD(' ', 3 * p_lev + 3) || '</attr>');
              ELSE
                str := str || '><![CDATA[' || val || ']]>';
                insert_txt(str);
                insert_txt(LPAD(' ', 3 * p_lev + 3) || '</attr>');
              END IF;
            END IF;
          END IF;
        END IF;
      END LOOP;
    
      insert_txt(LPAD(' ', 3 * p_lev) || '</ent>');
    END IF;
  END;

  /*******************************************************************************/

  PROCEDURE cre_key_tag
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_lev    IN NUMBER
  ) IS
    str          VARCHAR2(32000);
    tmp_str      VARCHAR2(32000);
    attr_table   list_of_names;
    val          VARCHAR2(32000);
    val_uro      NUMBER;
    is_reference BOOLEAN := TRUE;
    val_ref      NUMBER;
  BEGIN
    IF p_lev <= G_MAX_LEV
    THEN
      --определяем набор ключевых аттрибутов для выгрузки в XML для текущей Сущности
      SELECT a.attr_id
            ,a.BRIEF
            ,a.COL_NAME
            ,a.IS_KEY     KEY
            ,AT.BRIEF     TYPE
            ,a.ref_ent_id
            ,NULL         BULK COLLECT
        INTO attr_table
        FROM attr a
        JOIN attr_type AT
          ON AT.ATTR_TYPE_ID = a.ATTR_TYPE_ID
       WHERE a.is_key = 1
         AND a.is_excl = 0
         AND a.ent_id IN (SELECT e.ent_id
                            FROM entity e
                           START WITH e.ent_id = p_ent_id
                          CONNECT BY e.ent_id = PRIOR e.parent_id);
    
      --дополняем REF_ENT_ID для сущности T_PROD_COEF данными из T_PROD_COEF_TYPE
      IF ent_io.BRIEF_BY_ID(p_ent_id) IN ('T_PROD_COEF')
      THEN
        FOR i IN attr_table.FIRST .. attr_table.LAST
        LOOP
          IF SUBSTR(attr_table(i).col_name, 1, 9) = 'CRITERIA_'
          THEN
            BEGIN
              EXECUTE IMMEDIATE 'select a.ATTRIBUT_ENT_ID' || ' from T_PROD_COEF pc' ||
                                ' join T_PROD_COEF_TYPE pct on pct.T_PROD_COEF_TYPE_ID = pc.T_PROD_COEF_TYPE_ID' ||
                                ' join T_ATTRIBUT a on a.T_ATTRIBUT_ID = pct.FACTOR_' ||
                                SUBSTR(attr_table(i).col_name, 10) || ' where pc.T_PROD_COEF_ID = ' ||
                                p_obj_id
                INTO val_ref;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                val_ref := NULL;
            END;
            attr_table(i).ref_ent_id := val_ref;
          END IF;
        END LOOP;
      END IF;
    
      --добавляем в XML ключевые аттрибуты для текущего объекта
      FOR i IN attr_table.FIRST .. attr_table.LAST
      LOOP
        --находим значение для текущего аттрибута
        BEGIN
          EXECUTE IMMEDIATE 'select ' || attr_table(i).col_name || ' from ' || view_by_id(p_ent_id) ||
                            ' where ' || primkey_by_id(p_ent_id) || '=' || p_obj_id
            INTO val;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            val := NULL;
        END;
      
        --проверяем наличие значения в справочнике для сущности T_PROD_COEF данными из T_PROD_COEF_TYPE
        IF ent_io.BRIEF_BY_ID(p_ent_id) IN ('T_PROD_COEF')
           AND SUBSTR(attr_table(i).col_name, 1, 9) = 'CRITERIA_'
        THEN
          IF attr_table(i).ref_ent_id IS NOT NULL
              AND val IS NOT NULL
              AND ent_io.check_exist(attr_table(i).ref_ent_id, val) = 1
          THEN
            is_reference := TRUE;
          ELSE
            is_reference := FALSE;
          END IF;
        ELSE
          is_reference := TRUE;
        END IF;
      
        --Проверка на заполненность поля URO_ID
        IF attr_table(i).TYPE = 'UR'
            AND SUBSTR(UPPER(attr_table(i).col_name), -6) = 'URE_ID'
        THEN
          BEGIN
            EXECUTE IMMEDIATE 'select ' || REPLACE(UPPER(attr_table(i).col_name), 'URE_ID', 'URO_ID') ||
                              '  from ' || brief_by_id(p_ent_id) || ' where ' ||
                              primkey_by_id(p_ent_id) || '=' || p_obj_id
              INTO val_uro;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              val_uro := NULL;
          END;
        
          IF val_uro IS NULL
          THEN
            attr_table(i).TYPE := 'RE';
          END IF;
        END IF;
      
        --строка в XML
        str := LPAD(' ', 3 * p_lev + 3) || '<key brief=''' || attr_table(i).COL_NAME || ''' type=''' || attr_table(i).TYPE || '''';
      
        IF attr_table(i).TYPE IN ('R')
            AND val IS NOT NULL
            AND is_reference
        THEN
          IF attr_table(i).ref_ent_id IS NULL
          THEN
            set_err_txt('Ошибка при выгрузке данных для сущности ' || brief_by_id(p_ent_id) ||
                        '. Для аттрибута-ссылки ' || attr_table(i).COL_NAME ||
                        ' не заполнено поле REF_ENT_ID' || CHR(10) ||
                        'Необходима корректировка настроек аттрибутов сущности (ATTR)');
          ELSE
            str := str || ' ref_ent=''' || brief_by_id(attr_table(i).ref_ent_id) || '''>';
            insert_txt(str);
            --формируем аттрибуты по "ключевым" тегам
            cre_key_tag(attr_table(i).ref_ent_id, TO_NUMBER(val), p_lev + 1);
            insert_txt(LPAD(' ', 3 * p_lev + 3) || '</key>');
          END IF;
        ELSE
          IF val IS NULL
          THEN
            str := str || ' val=''''/>'; --||val||'''/>';
            insert_txt(str);
          ELSE
            --если есть аттрибут-ссылка на таблицу Сущностей
            IF attr_table(i).TYPE = 'RE'
            THEN
              str := str || '><![CDATA[' || brief_by_id(val) || ']]>';
              insert_txt(str);
              insert_txt(LPAD(' ', 3 * p_lev + 3) || '</key>');
            ELSE
              IF attr_table(i).TYPE = 'UR'
              THEN
                str := str || ' ref_ent=''' || brief_by_id(val) || '''>';
                insert_txt(str);
                --формируем аттрибуты по "ключевым" тегам
                EXECUTE IMMEDIATE 'select ' ||
                                  REPLACE(UPPER(attr_table(i).col_name), 'URE_ID', 'URO_ID') ||
                                  '  from ' || brief_by_id(p_ent_id) || ' where ' ||
                                  primkey_by_id(p_ent_id) || '=' || p_obj_id
                  INTO val_uro;
              
                cre_key_tag(val, val_uro, p_lev + 1);
                insert_txt(LPAD(' ', 3 * p_lev + 3) || '</attr>');
              ELSE
                str := str || '><![CDATA[' || val || ']]>';
                insert_txt(str);
                insert_txt(LPAD(' ', 3 * p_lev + 3) || '</key>');
              END IF;
            END IF;
          END IF;
        END IF;
      
      END LOOP;
    END IF;
  END;

  /*******************************************************************************/

  FUNCTION load_xml
  (
    dir     VARCHAR2 DEFAULT NULL
   ,inpfile VARCHAR2 DEFAULT NULL
   ,errfile VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    p   xmlparser.parser;
    doc xmldom.DOMDocument;
  
    /*******************************/
    --удаление в базе записей, связанных с обновляемым объектом
    PROCEDURE delete_by_fld_del
    (
      p_ent_id IN NUMBER
     ,p_obj_id IN NUMBER
    ) IS
      v_id NUMBER;
      TYPE ref_obj IS REF CURSOR;
      cur_ref ref_obj;
    BEGIN
      FOR cur_attr IN (SELECT ENT_ID
                             ,COL_NAME
                         FROM attr a
                        WHERE a.ref_ent_id = p_ent_id
                          AND a.FLG_DEL = 1)
      LOOP
        OPEN cur_ref FOR 'select ' || primkey_by_id(cur_attr.ent_id) || '  from ' || brief_by_id(cur_attr.ent_id) || ' where ' || cur_attr.col_name || ' = ' || p_obj_id;
        LOOP
          FETCH cur_ref
            INTO v_id;
          EXIT WHEN cur_ref%NOTFOUND;
        
          IF v_id IS NOT NULL
          THEN
            delete_by_fld_del(cur_attr.ent_id, v_id);
            BEGIN
              EXECUTE IMMEDIATE 'delete from ' || brief_by_id(cur_attr.ent_id) || ' where ' ||
                                cur_attr.col_name || ' = ' || p_obj_id;
            EXCEPTION
              WHEN OTHERS THEN
                set_err_txt('Ошибка удаления записей, связанных с объектом  через FLG_DEL=1' ||
                            CHR(10) || 'Ошибка выполнения оператора:' || CHR(10) || 'delete from ' ||
                            brief_by_id(cur_attr.ent_id) || ' where ' || cur_attr.col_name || ' = ' ||
                            p_obj_id || CHR(10) || SQLERRM);
            END;
          END IF;
        END LOOP;
        CLOSE cur_ref;
      
      END LOOP;
    END;
  
    /*******************************/
    --поиск в базе объекта с аналогичными ключевыми аттрибутами
    FUNCTION get_key_id
    (
      p_ent_id IN NUMBER
     ,p_whr    VARCHAR2
    ) RETURN VARCHAR2 IS
      key_id VARCHAR2(100);
      cnt    NUMBER;
      str    VARCHAR2(32000);
    BEGIN
      IF p_whr IS NOT NULL
      THEN
        BEGIN
          EXECUTE IMMEDIATE 'select count(*) from ' || view_by_id(p_ent_id) || p_whr
            INTO cnt;
        EXCEPTION
          WHEN OTHERS THEN
            set_err_txt('Ошибка при получении количества совпадающих объектов сущности ' ||
                        brief_by_id(p_ent_id) || ' при выполнении оператора: ' || CHR(10) ||
                        'select count(*) from ' || view_by_id(p_ent_id) || p_whr || CHR(10) ||
                        SQLERRM);
        END;
        IF cnt > 1
        THEN
          set_err_txt('Не удаётся идентифицировать объект сущности ' || brief_by_id(p_ent_id) ||
                      ': вместо одного объекта найдено ' || cnt || CHR(10) || ' Команда:' || CHR(10) ||
                      'select count(*) from ' || view_by_id(p_ent_id) || p_whr);
        ELSE
          BEGIN
            EXECUTE IMMEDIATE 'select ' || primkey_by_id(p_ent_id) || ' from ' || view_by_id(p_ent_id) ||
                              p_whr
              INTO key_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RETURN NULL;
            WHEN OTHERS THEN
              set_err_txt('Ошибка получения ID обрабатываемого объекта для сущности ' ||
                          brief_by_id(p_ent_id) || ' при выполнении оператора: ' || CHR(10) ||
                          'select ' || primkey_by_id(p_ent_id) || ' from ' || view_by_id(p_ent_id) ||
                          p_whr || CHR(10) || SQLERRM);
          END;
        END IF;
      END IF;
      RETURN key_id;
    END;
    /*******************************/
    --insert в БД загружаемый объект
    PROCEDURE insert_obj
    (
      p_ent_id IN NUMBER
     ,p_col    IN VARCHAR2
     ,p_val    IN VARCHAR2
    ) IS
      tmp_str VARCHAR2(32000);
    BEGIN
      IF (p_col IS NOT NULL)
         AND (p_val IS NOT NULL)
      THEN
        EXECUTE IMMEDIATE 'insert into ' || view_by_id(p_ent_id) || ' (' || p_col || ') ' ||
                          ' values (' || p_val || ')';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        set_err_txt('Ошибка загрузки объекта сущности ' || brief_by_id(p_ent_id) || ' оператором: ' ||
                    CHR(10) || 'insert into ' || view_by_id(p_ent_id) || ' (' || p_col || ') ' ||
                    ' values (' || p_val || ')' || CHR(10) || SQLERRM);
      
    END;
    /*******************************/
    --update в БД существующий объект
    PROCEDURE update_obj
    (
      p_ent_id IN NUMBER
     ,p_key_id IN NUMBER
     ,p_col    IN VARCHAR2
     ,p_val    IN VARCHAR2
    ) IS
      tmp_str VARCHAR2(32000);
    BEGIN
      IF (p_col IS NOT NULL)
         AND (p_val IS NOT NULL)
      THEN
        EXECUTE IMMEDIATE 'update ' || view_by_id(p_ent_id) || ' set (' || p_col || ')=(select ' ||
                          p_val || ' from dual) where ' || primkey_by_id(p_ent_id) || '=' || p_key_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        set_err_txt('Ошибка обновления объекта с ID = ' || p_key_id || ' сущности ' ||
                    brief_by_id(p_ent_id) || ' оператором: ' || CHR(10) || 'update ' ||
                    view_by_id(p_ent_id) || ' set (' || p_col || ')=(select ' || p_val ||
                    ' from dual) where ' || primkey_by_id(p_ent_id) || '=' || p_key_id || CHR(10) ||
                    SQLERRM);
    END;
    /*******************************/
    --insert/update в БД загружаемый объект сущности
    PROCEDURE ins_obj
    (
      p_ent_id IN NUMBER
     ,p_list   IN list_of_names
     ,p_is_key IN BOOLEAN
     ,p_key_id OUT VARCHAR2
    ) IS
      p_columns VARCHAR2(32000);
      p_values  VARCHAR2(32000);
      p_where   VARCHAR2(32000);
    BEGIN
      FOR i IN p_list.FIRST .. p_list.LAST
      LOOP
        IF i = p_list.FIRST
        THEN
          IF p_list(i).TYPE = 'UR'
          THEN
            p_columns := p_list(i).COL_NAME || ',' || REPLACE(p_list(i).COL_NAME, 'URE_ID', 'URO_ID');
            IF p_list(i).val IS NULL
            THEN
              p_values := 'NULL,NULL';
            ELSE
              p_values := '''' || p_list(i).ref_ent_id || ''',''' || p_list(i).val || '''';
            END IF;
          ELSE
            p_columns := p_list(i).COL_NAME;
            IF p_list(i).val IS NULL
            THEN
              p_values := 'NULL';
            ELSE
              p_values := '''' || REPLACE(p_list(i).val, '''', '''''') || '''';
            END IF;
          END IF;
        ELSE
          IF p_list(i).TYPE = 'UR'
          THEN
            p_columns := p_columns || ',' || p_list(i).COL_NAME || ',' ||
                         REPLACE(p_list(i).COL_NAME, 'URE_ID', 'URO_ID');
            IF p_list(i).val IS NULL
            THEN
              p_values := p_values || ',NULL,NULL';
            ELSE
              p_values := p_values || ',''' || p_list(i).ref_ent_id || ''',''' || p_list(i).val || '''';
            END IF;
          ELSE
            p_columns := p_columns || ',' || p_list(i).COL_NAME;
            IF p_list(i).val IS NULL
            THEN
              p_values := p_values || ',NULL';
            ELSE
              p_values := p_values || ',''' || REPLACE(p_list(i).val, '''', '''''') || '''';
            END IF;
          END IF;
        END IF;
      
        IF p_list(i).KEY = 1
        THEN
          IF p_where IS NULL
          THEN
            IF p_list(i).val IS NULL
            THEN
              p_where := ' where ' || p_list(i).COL_NAME || ' IS NULL';
            ELSE
              p_where := ' where ' || p_list(i).COL_NAME || '=''' ||
                         REPLACE(p_list(i).val, '''', '''''') || '''';
            END IF;
          ELSE
            IF p_list(i).val IS NULL
            THEN
              p_where := p_where || ' and ' || p_list(i).COL_NAME || ' IS NULL';
            ELSE
              p_where := p_where || ' and ' || p_list(i).COL_NAME || '=''' ||
                         REPLACE(p_list(i).val, '''', '''''') || '''';
            END IF;
          END IF;
        END IF;
      END LOOP;
    
      p_key_id := get_key_id(p_ent_id, p_where);
      IF NOT p_is_key
      THEN
        IF p_key_id IS NULL
        THEN
          insert_obj(p_ent_id, p_columns, p_values);
          p_key_id := get_key_id(p_ent_id, p_where);
        ELSE
          delete_by_fld_del(p_ent_id, p_key_id);
          update_obj(p_ent_id, p_key_id, p_columns, p_values);
        END IF;
      ELSIF p_key_id IS NULL
      THEN
        set_err_txt('В базе не найдена запись, на которую идёт ссылка по запросу: ' || CHR(10) ||
                    'select ' || primkey_by_id(p_ent_id) || ' from ' || view_by_id(p_ent_id) ||
                    p_where);
      END IF;
    EXCEPTION
      WHEN VALUE_ERROR THEN
        set_err_txt('Ошибка преобразования числа или значения для сущности ' || brief_by_id(p_ent_id) ||
                    CHR(10) || 'Столбцы: ' || p_columns || CHR(10) || 'Значения:' || p_values);
    END;
  
    --парсим xml-файл в иерархической последовательности
    PROCEDURE load_node
    (
      p_ent_id IN NUMBER
     ,p_node   IN xmldom.DOMNode
     ,p_is_key IN BOOLEAN
     ,p_key_id OUT VARCHAR2
    ) IS
      p_attr_table list_of_names;
      n_parent     xmldom.DOMNode;
      n_child      xmldom.DOMNode;
      len          NUMBER;
      child_num    NUMBER := 0;
      node_map     xmldom.DOMNamedNodeMap;
      is_val_tag   BOOLEAN;
    BEGIN
      p_key_id := '';
      n_parent := xmldom.GETFIRSTCHILD(p_node);
    
      WHILE n_parent.ID != -1
      LOOP
        node_map := xmldom.GETATTRIBUTES(n_parent);
        IF (xmldom.isNull(node_map) = FALSE)
        THEN
          len        := xmldom.getLength(node_map);
          is_val_tag := FALSE;
          FOR i IN 0 .. len - 1
          LOOP
            n_child := xmldom.ITEM(node_map, i);
            CASE UPPER(xmldom.getNodeName(n_child))
              WHEN 'BRIEF' THEN
                p_attr_table(child_num).COL_NAME := UPPER(xmldom.getNodeValue(n_child));
              WHEN 'KEY' THEN
                CASE UPPER(xmldom.getNodeValue(n_child))
                  WHEN 'Y' THEN
                    p_attr_table(child_num).KEY := 1;
                  WHEN 'N' THEN
                    p_attr_table(child_num).KEY := 0;
                END CASE;
              WHEN 'TYPE' THEN
                p_attr_table(child_num).TYPE := UPPER(xmldom.getNodeValue(n_child));
              WHEN 'REF_ENT' THEN
                p_attr_table(child_num).ref_ent_id := id_by_brief(UPPER(xmldom.getNodeValue(n_child)));
                IF UPPER(xmldom.getNodeValue(n_child)) IS NOT NULL
                   AND p_attr_table(child_num).ref_ent_id IS NULL
                THEN
                  set_err_txt('Ошибка загрузки объекта сущности. Не найдена Сущность с именем ' ||
                              UPPER(xmldom.getNodeValue(n_child)) || '.' || CHR(10) ||
                              'Требуется обновление структуры БД');
                END IF;
                load_node(p_attr_table(child_num).ref_ent_id
                         ,n_parent
                         ,TRUE
                         ,p_attr_table(child_num).val);
                is_val_tag := TRUE;
              WHEN 'VAL' THEN
                IF p_attr_table(child_num).TYPE = 'RE'
                    AND xmldom.getNodeValue(n_child) IS NOT NULL
                THEN
                  p_attr_table(child_num).val := id_by_brief(UPPER(xmldom.getNodeValue(n_child)));
                  IF p_attr_table(child_num).val IS NULL
                  THEN
                    set_err_txt('Ошибка загрузки объекта сущности. Не найдена Сущность с именем ' ||
                                UPPER(xmldom.getNodeValue(n_child)) || '.' || CHR(10) ||
                                'Требуется обновление структуры БД');
                  END IF;
                ELSE
                  p_attr_table(child_num).val := xmldom.getNodeValue(n_child);
                END IF;
                is_val_tag := TRUE;
            END CASE;
          
            IF UPPER(xmldom.getNodeName(n_parent)) = 'KEY'
            THEN
              p_attr_table(child_num).KEY := 1;
            END IF;
          
            IF NOT is_val_tag
               AND i = len - 1
            THEN
              IF p_attr_table(child_num).TYPE = 'RE'
              THEN
                p_attr_table(child_num).val := id_by_brief(UPPER(xmldom.getNodeValue(xmldom.GETFIRSTCHILD(n_parent))));
                IF UPPER(xmldom.getNodeValue(xmldom.GETFIRSTCHILD(n_parent))) IS NOT NULL
                   AND p_attr_table(child_num).val IS NULL
                THEN
                  set_err_txt('Ошибка загрузки объекта сущности. Не найдена Сущность с именем ' ||
                              UPPER(xmldom.getNodeValue(xmldom.GETFIRSTCHILD(n_parent))) || '.' ||
                              CHR(10) || 'Требуется обновление структуры БД');
                END IF;
              ELSE
                p_attr_table(child_num).val := xmldom.getNodeValue(xmldom.GETFIRSTCHILD(n_parent));
              END IF;
            END IF;
          
          END LOOP;
        END IF;
        n_parent  := xmldom.GETNEXTSIBLING(n_parent);
        child_num := child_num + 1;
      END LOOP;
      ins_obj(p_ent_id, p_attr_table, NVL(p_is_key, FALSE), p_key_id);
    END;
  
    --парсим xml-файл в иерархической последовательности
    PROCEDURE load_node
    (
      p_ent_id IN NUMBER
     ,p_node   IN xmldom.DOMNode
    ) IS
      txt VARCHAR2(32000);
    BEGIN
      load_node(p_ent_id, p_node, FALSE, txt);
    END;
  
    --парсим xml-файл по отдельным Объектам сущности
    PROCEDURE load_data(doc xmldom.DOMDocument) IS
      attrval  VARCHAR2(100);
      node_lst xmldom.DOMNodeList;
      cur_node xmldom.DOMNode;
      nnm      xmldom.DOMNamedNodeMap;
    BEGIN
    
      -- получаем список тегов
      node_lst := xmldom.getElementsByTagName(doc, '*');
      cur_node := xmldom.item(node_lst, 1);
    
      --dbms_output.put_line('Begin');
      --пробегаем по загружаемым объектам сущности
      WHILE cur_node.ID != -1
      LOOP
        nnm     := xmldom.GETATTRIBUTES(cur_node);
        attrval := UPPER(xmldom.getNodeValue(xmldom.item(nnm, 0)));
        --dbms_output.put_line(chr(10)||attrval);
        load_node(id_by_brief(attrval), cur_node);
        cur_node := xmldom.GETNEXTSIBLING(cur_node);
      END LOOP;
      --dbms_output.put_line('End');
    END;
  
  BEGIN
    --создаём новый парсер
    p := xmlparser.newParser;
  
    IF xml_file IS NOT NULL
    THEN
      xmlparser.PARSECLOB(p, xml_file);
    ELSE
      IF dir IS NOT NULL
         AND inpfile IS NOT NULL
      THEN
      
        --начальные настройки
        xmlparser.setValidationMode(p, FALSE);
        xmlparser.setErrorLog(p, dir || '/' || errfile);
        xmlparser.setBaseDir(p, dir);
      
        --парсим xml-файл
        xmlparser.parse(p, dir || '/' || inpfile);
      END IF;
    END IF;
  
    --получаем ссылку на документ
    doc := xmlparser.getDocument(p);
  
    --выполняем загрузку Объектов сущности
    load_data(doc);
    COMMIT;
    RETURN 1;
  
  EXCEPTION
    WHEN xmldom.INDEX_SIZE_ERR THEN
      RAISE_APPLICATION_ERROR(-20120, 'Index Size error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.DOMSTRING_SIZE_ERR THEN
      RAISE_APPLICATION_ERROR(-20121, 'String Size error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.HIERARCHY_REQUEST_ERR THEN
      RAISE_APPLICATION_ERROR(-20122, 'Hierarchy request error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.WRONG_DOCUMENT_ERR THEN
      RAISE_APPLICATION_ERROR(-20123, 'Wrong doc error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.INVALID_CHARACTER_ERR THEN
      RAISE_APPLICATION_ERROR(-20124, 'Invalid Char error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NO_DATA_ALLOWED_ERR THEN
      RAISE_APPLICATION_ERROR(-20125, 'Nod data allowed error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NO_MODIFICATION_ALLOWED_ERR THEN
      RAISE_APPLICATION_ERROR(-20126, 'No mod allowed error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NOT_FOUND_ERR THEN
      RAISE_APPLICATION_ERROR(-20127, 'Not found error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NOT_SUPPORTED_ERR THEN
      RAISE_APPLICATION_ERROR(-20128, 'Not supported error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.INUSE_ATTRIBUTE_ERR THEN
      RAISE_APPLICATION_ERROR(-20129, 'In use attr error');
      ROLLBACK;
      RETURN 0;
    
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  /*******************************************************************************/

  --линии по Продукту
  FUNCTION exp_prod_line
  (
    p_product_line_id          NUMBER
   ,p_exp_prod_coef_type_by_id NUMBER DEFAULT 1
   ,p_exp_questionnaire_type   NUMBER DEFAULT 1
   ,p_tmp_xml_id               NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    x NUMBER;
    s VARCHAR2(1000);
    n NUMBER;
  
    --Группы Рисков
    PROCEDURE exp_prod_line_opt
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_line_opt IN (SELECT *
                             FROM T_PROD_LINE_OPTION plo
                            WHERE plo.product_line_id = p_product_line_id)
      LOOP
        --группа Рисков
        ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_OPTION'), rec_line_opt.ID, p_xml_id, NULL, s);
      
        --риски Группы Рисков
        FOR rec_line_opt_peril IN (SELECT *
                                     FROM T_PROD_LINE_OPT_PERIL plop
                                    WHERE plop.PRODUCT_LINE_OPTION_ID = rec_line_opt.ID)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_PERIL')
                              ,NVL(rec_line_opt_peril.peril_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
        
          --риск Группы Рисков
          ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_OPT_PERIL')
                              ,rec_line_opt_peril.ID
                              ,p_xml_id
                              ,NULL
                              ,s);
        
          /*
          --иерархия T_DAMAGE_CODE
          for rec_dam in
                           (select *
                              from T_DAMAGE_CODE dc
                             start with dc.peril = rec_line_opt_peril.peril_id
                           connect by dc.id = prior dc.parent_id
                             order by level desc)
          loop
            ENT_IO.append_to_XML(id_by_brief('T_PERIL'),nvl(rec_dam.peril,-555),p_xml_id,null,s);
            ENT_IO.append_to_XML(id_by_brief('T_DAMAGE_CODE'),rec_dam.id,p_xml_id,null,s);
          
            --коды Ущерба
            for cur_line_damage in
                                 (select *
                                    from T_PROD_LINE_DAMAGE pld
                                   where pld.T_DAMAGE_CODE_ID=rec_dam.id)
            loop
              ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_DAMAGE'),cur_line_damage.t_prod_line_damage_id,p_xml_id,null,s);
            end loop;
          end loop;
          */
        
          --коды Ущерба
          FOR cur_line_damage IN (SELECT *
                                    FROM T_PROD_LINE_DAMAGE pld
                                   WHERE pld.T_PROD_LINE_OPT_PERIL_ID = rec_line_opt_peril.ID)
          LOOP
          
            --иерархия T_DAMAGE_CODE
            FOR cur_dam IN (SELECT *
                              FROM T_DAMAGE_CODE dc
                             START WITH dc.ID = cur_line_damage.t_damage_code_id
                            CONNECT BY dc.ID = PRIOR dc.parent_id
                             ORDER BY LEVEL DESC)
            LOOP
              ENT_IO.append_to_XML(id_by_brief('T_PERIL')
                                  ,NVL(cur_dam.peril, -555)
                                  ,p_xml_id
                                  ,NULL
                                  ,s);
              ENT_IO.append_to_XML(id_by_brief('T_DAMAGE_CODE'), cur_dam.ID, p_xml_id, NULL, s);
            END LOOP;
          
            --процедура экспорта коэф. тарифа
            --exp_coef(x))
          
            --код Ущерба
            ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_DAMAGE')
                                ,cur_line_damage.t_prod_line_damage_id
                                ,p_xml_id
                                ,NULL
                                ,s);
          END LOOP;
        END LOOP;
      END LOOP;
    END;
  
    --Франшиза
    PROCEDURE exp_prod_line_deduct
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR cur_deduct IN (SELECT *
                           FROM T_PROD_LINE_DEDUCT pld
                          WHERE pld.PRODUCT_LINE_ID = p_product_line_id)
      LOOP
        FOR cur_deduct_rel IN (SELECT *
                                 FROM T_DEDUCTIBLE_REL dr
                                WHERE dr.T_DEDUCTIBLE_REL_ID = cur_deduct.deductible_rel_id)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_DEDUCTIBLE_TYPE')
                              ,NVL(cur_deduct_rel.deductible_type_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('T_DEDUCT_VAL_TYPE')
                              ,NVL(cur_deduct_rel.deductible_value_type_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('T_DEDUCTIBLE_REL')
                              ,cur_deduct_rel.t_deductible_rel_id
                              ,p_xml_id
                              ,NULL
                              ,s);
        END LOOP;
      
        --франшиза
        ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_DEDUCT'), cur_deduct.ID, p_xml_id, NULL, s);
      END LOOP;
    END;
  
    --Анкеты
    PROCEDURE exp_prod_line_form
    (
      p_as_type_prod_line_id NUMBER
     ,p_xml_id               NUMBER
    ) IS
      s VARCHAR2(1000);
      n NUMBER;
    BEGIN
      FOR cur_question IN (SELECT *
                             FROM T_PROD_LINE_FORM plf
                            WHERE plf.T_AS_TYPE_PROD_LINE_ID = p_as_type_prod_line_id)
      LOOP
        --Анкеты
        IF p_exp_questionnaire_type = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('QUESTIONNAIRE_TYPE')
                              ,NVL(cur_question.questionnaire_type_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_questionnaire_type_by_id(cur_question.questionnaire_type_id, p_xml_id);
        END IF;
      
        ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_FORM')
                            ,cur_question.T_PROD_LINE_FORM_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Коэф. тарифа
    PROCEDURE exp_prod_line_coef
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
      n NUMBER;
    BEGIN
      FOR cur_line_coef IN (SELECT *
                              FROM T_PROD_LINE_COEF plc
                             WHERE plc.T_PRODUCT_LINE_ID = p_product_line_id)
      LOOP
        --процедура экспорта коэф. тарифа
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,NVL(cur_line_coef.t_prod_coef_type_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(cur_line_coef.t_prod_coef_type_id, p_xml_id);
        END IF;
      
        --коэффициент
        ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_COEF')
                            ,cur_line_coef.t_prod_line_coef_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --права на изменение тарифа
        FOR cur_saf IN (SELECT *
                          FROM T_PROD_LINE_COEF_SAF cs
                         WHERE cs.T_PROD_LINE_COEF_ID = cur_line_coef.T_PROD_LINE_COEF_ID)
        LOOP
          FOR cur_right IN (SELECT *
                              FROM SAFETY_RIGHT sr
                             WHERE sr.SAFETY_RIGHT_ID = cur_saf.SAFETY_RIGHT_ID)
          LOOP
            ENT_IO.append_to_XML(id_by_brief('SAFETY_RIGHT_TYPE')
                                ,NVL(cur_right.SAFETY_RIGHT_TYPE_ID, -555)
                                ,p_xml_id
                                ,NULL
                                ,s);
            ENT_IO.append_to_XML(id_by_brief('SAFETY_RIGHT')
                                ,cur_right.SAFETY_RIGHT_ID
                                ,p_xml_id
                                ,NULL
                                ,s);
          END LOOP;
          ENT_IO.append_to_XML(id_by_brief('T_PROD_LINE_COEF_SAF')
                              ,cur_saf.t_prod_line_coef_saf_id
                              ,p_xml_id
                              ,NULL
                              ,s);
        END LOOP;
      END LOOP;
    END;
  
    --Виды объектов
    PROCEDURE exp_as_type_prod_line
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR cur_as_type_prod_line IN (SELECT *
                                      FROM T_AS_TYPE_PROD_LINE atpl
                                     WHERE atpl.PRODUCT_LINE_ID = p_product_line_id)
      LOOP
        --иерархия T_DAMAGE_CODE
        FOR cur_asset_type IN (SELECT *
                                 FROM T_ASSET_TYPE AT
                                START WITH AT.t_asset_type_id =
                                           cur_as_type_prod_line.asset_common_type_id
                               CONNECT BY AT.t_asset_type_id = PRIOR AT.parent_id
                                ORDER BY LEVEL DESC)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_ASSET_TYPE')
                              ,cur_asset_type.t_asset_type_id
                              ,p_xml_id
                              ,NULL
                              ,s);
        END LOOP;
      
        --Функция расчета страховой суммы по объекту страхования
        IF cur_as_type_prod_line.ins_amount_func_id IS NOT NULL
        THEN
          x := ENT_IO.exp_prod_coef_type_by_id(cur_as_type_prod_line.ins_amount_func_id, x);
        END IF;
      
        --вид Объекта
        ENT_IO.append_to_XML(id_by_brief('T_AS_TYPE_PROD_LINE')
                            ,cur_as_type_prod_line.t_as_type_prod_line_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --анкеты, привязанные к Объекту
        exp_prod_line_form(cur_as_type_prod_line.T_AS_TYPE_PROD_LINE_ID, p_xml_id);
      END LOOP;
    END;
  
    --Родительская программа
    PROCEDURE exp_parent_prod_line
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR cur_parent_prod_line IN (SELECT *
                                     FROM parent_prod_line ppl
                                    WHERE ppl.T_PROD_LINE_ID = p_product_line_id)
      LOOP
        n := ENT_IO.exp_prod_line(cur_parent_prod_line.T_PARENT_PROD_LINE_ID
                                 ,p_exp_prod_coef_type_by_id
                                 ,p_exp_questionnaire_type
                                 ,p_xml_id);
        ENT_IO.append_to_XML(id_by_brief('PARENT_PROD_LINE')
                            ,cur_parent_prod_line.PARENT_PROD_LINE_ID
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Конкурирующая программа
    PROCEDURE exp_concurrent_prod_line
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR cur_concur_prod_line IN (SELECT *
                                     FROM concurrent_prod_line cpl
                                    WHERE cpl.T_PRODUCT_LINE_ID = p_product_line_id)
      LOOP
        n := ENT_IO.exp_prod_line(cur_concur_prod_line.T_CONCUR_PRODUCT_LINE_ID
                                 ,p_exp_prod_coef_type_by_id
                                 ,p_exp_questionnaire_type
                                 ,p_xml_id);
        ENT_IO.append_to_XML(id_by_brief('CONCURRENT_PROD_LINE')
                            ,cur_concur_prod_line.CONCURRENT_PROD_LINE_ID
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Контроль претензии
    PROCEDURE exp_prod_claim_control
    (
      p_product_line_id NUMBER
     ,p_xml_id          NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR cur_prod_claim_control IN (SELECT *
                                       FROM t_prod_claim_control pcc
                                      WHERE pcc.T_PRODUCT_LINE_ID = p_product_line_id)
      LOOP
      
        IF cur_prod_claim_control.control_func_id IS NOT NULL
        THEN
          x := ENT_IO.exp_prod_coef_type_by_id(cur_prod_claim_control.control_func_id, p_xml_id);
        END IF;
      
        ENT_IO.append_to_XML(id_by_brief('T_PROD_CLAIM_CONTROL')
                            ,cur_prod_claim_control.t_prod_claim_control_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
  BEGIN
  
    FOR rec_prod_line IN (SELECT * FROM T_PRODUCT_LINE pl WHERE pl.ID = p_product_line_id)
    LOOP
      IF p_tmp_xml_id IS NULL
      THEN
        ENT_IO.open_xml(x);
      ELSE
        x := p_tmp_xml_id;
      END IF;
    
      --справочники
      ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_LINE_TYPE')
                          ,NVL(rec_prod_line.product_line_type_id, -555)
                          ,x
                          ,NULL
                          ,s);
      ENT_IO.append_to_XML(id_by_brief('T_PREMIUM_TYPE')
                          ,NVL(rec_prod_line.premium_type, -555)
                          ,x
                          ,NULL
                          ,s);
      ENT_IO.append_to_XML(id_by_brief('T_ROUND_RULES')
                          ,NVL(rec_prod_line.fee_round_rules_id, -555)
                          ,x
                          ,NULL
                          ,s);
      ENT_IO.append_to_XML(id_by_brief('T_ROUND_RULES')
                          ,NVL(rec_prod_line.ins_amount_round_rules_id, -555)
                          ,x
                          ,NULL
                          ,s);
      ENT_IO.append_to_XML(id_by_brief('T_COVER_FORM')
                          ,NVL(rec_prod_line.t_cover_form_id, -555)
                          ,x
                          ,NULL
                          ,s);
      ENT_IO.append_to_XML(id_by_brief('T_PROLONG_ALG')
                          ,NVL(rec_prod_line.t_prolong_alg_id, -555)
                          ,x
                          ,NULL
                          ,s);
    
      --ИД функции по расчету франшизы
      IF rec_prod_line.DEDUCT_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.DEDUCT_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.DEDUCT_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.DEDUCT_FUNC_ID,p_xml_id);
      END IF;
    
      --Функция расчета брутто взноса
      IF rec_prod_line.FEE_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE'), rec_prod_line.FEE_FUNC_ID, x, NULL, s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.FEE_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.FEE_FUNC_ID,p_xml_id);
      END IF;
    
      --Функция расчета немедицинского коэффициента К, нагружающего тариф
      IF rec_prod_line.K_COEF_NM_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.K_COEF_NM_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.K_COEF_NM_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.K_COEF_NM_FUNC_ID,x);
      END IF;
    
      --Функция расчета нагрузки по программе
      IF rec_prod_line.LOADING_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.LOADING_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.LOADING_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.LOADING_FUNC_ID,x);
      END IF;
    
      --ИД функции для расчета стоимости
      IF rec_prod_line.INS_PRICE_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.INS_PRICE_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.INS_PRICE_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.INS_PRICE_FUNC_ID,x);
      END IF;
    
      --ИД функции для расчета страховой суммы
      IF rec_prod_line.INS_AMOUNT_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.INS_AMOUNT_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.INS_AMOUNT_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.INS_AMOUNT_FUNC_ID,x);
      END IF;
    
      --Функция расчета нетто тарифа
      IF rec_prod_line.TARIFF_NETTO_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.TARIFF_NETTO_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.TARIFF_NETTO_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.TARIFF_NETTO_FUNC_ID,x);
      END IF;
    
      --ИД функции для расчета тарифа
      IF rec_prod_line.TARIFF_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.TARIFF_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.TARIFF_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.TARIFF_FUNC_ID,x);
      END IF;
    
      --Функция расчета немедицинского коэффициента S, нагружающего тариф
      IF rec_prod_line.S_COEF_NM_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.S_COEF_NM_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.S_COEF_NM_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.S_COEF_NM_FUNC_ID,x);
      END IF;
    
      --ИД функции для расчета премии
      IF rec_prod_line.PREMIUM_FUNC_ID IS NOT NULL
      THEN
        IF p_exp_prod_coef_type_by_id = 0
        THEN
          ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                              ,rec_prod_line.PREMIUM_FUNC_ID
                              ,x
                              ,NULL
                              ,s);
        ELSE
          n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.PREMIUM_FUNC_ID, x);
        END IF;
      
        --n := ENT_IO.exp_prod_coef_type_by_id(rec_prod_line.PREMIUM_FUNC_ID,x);
      END IF;
    
      --линия по Продукту
      ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_LINE'), rec_prod_line.ID, x, NULL, s);
    
      --группы Рисков
      exp_prod_line_opt(rec_prod_line.ID, x);
    
      --Франшиза
      exp_prod_line_deduct(rec_prod_line.ID, x);
    
      --Коэф. тарифа
      exp_prod_line_coef(rec_prod_line.ID, x);
    
      --Виды объектов
      exp_as_type_prod_line(rec_prod_line.ID, x);
    
      --Зависимость
      exp_parent_prod_line(rec_prod_line.ID, x);
      exp_concurrent_prod_line(rec_prod_line.ID, x);
    
      --Контроль претензии
      exp_prod_claim_control(rec_prod_line.ID, x);
    
    END LOOP;
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_product_by_id
  (
    p_product_id               NUMBER
   ,p_exp_prod_coef_type_by_id NUMBER DEFAULT 1
   ,p_exp_questionnaire_type   NUMBER DEFAULT 1
  ) RETURN NUMBER IS
    x  NUMBER;
    n  NUMBER;
    st VARCHAR2(1000);
  
    --Условия встепления в силу
    PROCEDURE exp_product_conf_cond
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_product_conf_cond IN (SELECT *
                                      FROM T_PRODUCT_CONF_COND pcc
                                     WHERE pcc.PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_CONFIRM_CONDITION')
                            ,NVL(rec_product_conf_cond.confirm_condition_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_CONF_COND')
                            ,rec_product_conf_cond.ID
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Рассторжение
    PROCEDURE exp_product_decline
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_product_decline IN (SELECT *
                                    FROM T_PRODUCT_DECLINE pd
                                   WHERE pd.T_PRODUCT_ID = p_product_id)
      LOOP
        FOR rec_decline_reason IN (SELECT *
                                     FROM T_DECLINE_REASON dr
                                    WHERE dr.T_DECLINE_REASON_ID =
                                          rec_product_decline.t_decline_reason_id)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_DECLINE_PARTY')
                              ,NVL(rec_decline_reason.t_decline_party_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('T_DECLINE_TYPE')
                              ,NVL(rec_decline_reason.t_decline_type_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('T_DECLINE_REASON')
                              ,rec_decline_reason.t_decline_reason_id
                              ,p_xml_id
                              ,NULL
                              ,s);
        END LOOP;
      
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_DECLINE')
                            ,rec_product_decline.t_product_decline_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Периоды действия
    PROCEDURE exp_prod_period
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_period IN (SELECT * FROM T_PRODUCT_PERIOD pp WHERE pp.PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_PERIOD')
                            ,NVL(rec_prod_period.period_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
        ENT_IO.append_to_XML(id_by_brief('T_PERIOD_USE_TYPE')
                            ,NVL(rec_prod_period.t_period_use_type_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --период
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_PERIOD'), rec_prod_period.ID, p_xml_id, NULL, s);
      END LOOP;
    END;
  
    --Валюта ответственности
    PROCEDURE exp_prod_cur
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_cur IN (SELECT * FROM T_PROD_CURRENCY pc WHERE pc.PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('FUND')
                            ,NVL(rec_prod_cur.currency_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --валюта
        ENT_IO.append_to_XML(id_by_brief('T_PROD_CURRENCY'), rec_prod_cur.ID, p_xml_id, NULL, s);
      END LOOP;
    END;
  
    --Валюта платежа для Продукта
    PROCEDURE exp_prod_pay_cur
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_pay_cur IN (SELECT * FROM T_PROD_PAY_CURR ppc WHERE ppc.PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('FUND')
                            ,NVL(rec_prod_pay_cur.currency_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --валюта
        ENT_IO.append_to_XML(id_by_brief('T_PROD_PAY_CURR'), rec_prod_pay_cur.ID, p_xml_id, NULL, s);
      END LOOP;
    END;
  
    --Тип Контакта для Продукта
    PROCEDURE exp_prod_cont_type
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_cont_type IN (SELECT *
                                   FROM T_PRODUCT_CONT_TYPE pct
                                  WHERE pct.PRODUCT_ID = p_product_id)
      LOOP
        --иерархия типов контакта
        FOR rec_con_type IN (SELECT *
                               FROM T_CONTACT_TYPE ct
                              START WITH ct.ID = rec_prod_cont_type.contact_type_id
                             CONNECT BY PRIOR ct.upper_level_id = ct.ID
                              ORDER BY LEVEL DESC)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_CONTACT_TYPE'), rec_con_type.ID, p_xml_id, NULL, s);
        END LOOP;
      
        --тип Контакта
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_CONT_TYPE')
                            ,rec_prod_cont_type.ID
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Каналы продаж по Продукту
    PROCEDURE exp_prod_sales_chan
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_sales_chan IN (SELECT *
                                    FROM T_PROD_SALES_CHAN psc
                                   WHERE psc.PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_SALES_CHANNEL')
                            ,NVL(rec_prod_sales_chan.sales_channel_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --канал Продаж
        ENT_IO.append_to_XML(id_by_brief('T_PROD_SALES_CHAN')
                            ,rec_prod_sales_chan.ID
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Платежи по Продукту
    PROCEDURE exp_prod_pay_terms
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_pay_terms IN (SELECT *
                                   FROM T_PROD_PAYMENT_TERMS ppt
                                  WHERE ppt.PRODUCT_ID = p_product_id)
      LOOP
        FOR rec_pay_terms IN (SELECT *
                                FROM T_PAYMENT_TERMS pt
                               WHERE pt.ID = rec_prod_pay_terms.payment_term_id)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_COLLECTION_METHOD')
                              ,NVL(rec_pay_terms.collection_method_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('T_PAYMENT_TERMS'), rec_pay_terms.ID, p_xml_id, NULL, s);
          FOR cur_pay_term_detail IN (SELECT *
                                        FROM T_PAY_TERM_DETAILS ptd
                                       WHERE ptd.PAYMENT_TERM_ID = rec_pay_terms.ID)
          LOOP
            ENT_IO.append_to_XML(id_by_brief('T_PAY_TERM_DETAILS')
                                ,cur_pay_term_detail.ID
                                ,p_xml_id
                                ,NULL
                                ,s);
          END LOOP;
        END LOOP;
      
        --платёж
        ENT_IO.append_to_XML(id_by_brief('T_PROD_PAYMENT_TERMS')
                            ,rec_prod_pay_terms.ID
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Выплаты по Продукту
    PROCEDURE exp_prod_claim_payterm
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_claim_payterm IN (SELECT *
                                       FROM T_PROD_CLAIM_PAYTERM pcp
                                      WHERE pcp.PRODUCT_ID = p_product_id)
      LOOP
        FOR rec_pay_terms IN (SELECT *
                                FROM T_PAYMENT_TERMS pt
                               WHERE pt.ID = rec_prod_claim_payterm.payment_terms_id)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_COLLECTION_METHOD')
                              ,NVL(rec_pay_terms.collection_method_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('T_PAYMENT_TERMS'), rec_pay_terms.ID, p_xml_id, NULL, s);
          FOR cur_pay_term_detail IN (SELECT *
                                        FROM T_PAY_TERM_DETAILS ptd
                                       WHERE ptd.PAYMENT_TERM_ID = rec_pay_terms.ID)
          LOOP
            ENT_IO.append_to_XML(id_by_brief('T_PAY_TERM_DETAILS')
                                ,cur_pay_term_detail.ID
                                ,p_xml_id
                                ,NULL
                                ,s);
          END LOOP;
        END LOOP;
      
        --выплата
        ENT_IO.append_to_XML(id_by_brief('T_PROD_CLAIM_PAYTERM')
                            ,rec_prod_claim_payterm.t_prod_claim_payterm_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Документы для получения выплаты
    PROCEDURE exp_prod_issuer_doc
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_issuer_doc IN (SELECT *
                                    FROM T_PROD_ISSUER_DOC pid
                                   WHERE pid.T_PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_ISSUER_DOC_TYPE')
                            ,NVL(rec_prod_issuer_doc.t_issuer_doc_type_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --докумень
        ENT_IO.append_to_XML(id_by_brief('T_PROD_ISSUER_DOC')
                            ,rec_prod_issuer_doc.t_prod_issuer_doc_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Отчёты
    PROCEDURE exp_rep_product
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_rep_product IN (SELECT * FROM REP_PRODUCT rp WHERE rp.T_PRODUCT_ID = p_product_id)
      LOOP
        --иерархия репортов
        FOR rec_rep_report IN (SELECT *
                                 FROM REP_REPORT rr
                                START WITH rr.rep_report_id = rec_rep_product.rep_report_id
                               CONNECT BY PRIOR rr.parent_id = rr.rep_report_id
                                ORDER BY LEVEL DESC)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('REP_TYPE')
                              ,NVL(rec_rep_report.rep_type_id, -555)
                              ,p_xml_id
                              ,NULL
                              ,s);
          ENT_IO.append_to_XML(id_by_brief('REP_REPORT')
                              ,rec_rep_report.rep_report_id
                              ,p_xml_id
                              ,NULL
                              ,s);
        END LOOP;
      
        ENT_IO.append_to_XML(id_by_brief('REP_KIND')
                            ,NVL(rec_rep_product.rep_kind_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --отчёт
        ENT_IO.append_to_XML(id_by_brief('REP_PRODUCT')
                            ,rec_rep_product.rep_product_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Типы доп.соглашений
    PROCEDURE exp_prod_addendum
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_addendum IN (SELECT *
                                  FROM T_PRODUCT_ADDENDUM pa
                                 WHERE pa.T_PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_ADDENDUM_TYPE')
                            ,NVL(rec_prod_addendum.t_addendum_type_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --тип доп. соглашения
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_ADDENDUM')
                            ,rec_prod_addendum.t_product_addendum_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --порядок выплаты
    PROCEDURE exp_prod_pay_ord
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_pay_ord IN (SELECT *
                                 FROM T_PROD_PAYMENT_ORDER ppo
                                WHERE ppo.T_PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_PAYMENT_ORDER')
                            ,NVL(rec_prod_pay_ord.t_payment_order_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --выплата
        ENT_IO.append_to_XML(id_by_brief('T_PROD_PAYMENT_ORDER')
                            ,rec_prod_pay_ord.t_prod_payment_order_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
    --Типы БСО
    PROCEDURE exp_prod_bso_type
    (
      p_product_id NUMBER
     ,p_xml_id     NUMBER
    ) IS
      s VARCHAR2(1000);
    BEGIN
      FOR rec_prod_bso_type IN (SELECT *
                                  FROM T_PRODUCT_BSO_TYPES pbt
                                 WHERE pbt.T_PRODUCT_ID = p_product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('BSO_TYPE')
                            ,NVL(rec_prod_bso_type.bso_type_id, -555)
                            ,p_xml_id
                            ,NULL
                            ,s);
      
        --канал Продаж
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_BSO_TYPES')
                            ,rec_prod_bso_type.t_product_bso_types_id
                            ,p_xml_id
                            ,NULL
                            ,s);
      END LOOP;
    END;
  
  BEGIN
    ENT_IO.open_xml(x);
  
    --первый шаг
    FOR cur_ins_grp IN (SELECT *
                          FROM t_insurance_group
                         START WITH parent_id IS NULL
                        CONNECT BY parent_id = PRIOR t_insurance_group_id)
    LOOP
      ENT_IO.append_to_XML(id_by_brief('T_INSURANCE_GROUP')
                          ,cur_ins_grp.t_insurance_group_id
                          ,x
                          ,NULL
                          ,st);
    END LOOP;
  
    ENT_IO.append_to_XML(id_by_brief('T_LOB'), NULL, x, NULL, st);
    ENT_IO.append_to_XML(id_by_brief('T_LOB_LINE'), NULL, x, NULL, st);
  
    --продукт
    FOR rec_prod IN (SELECT * FROM T_PRODUCT p WHERE p.PRODUCT_ID = p_product_id)
    LOOP
      --справочники для Продукта
      ENT_IO.append_to_XML(id_by_brief('BSO_TYPE'), NVL(rec_prod.bso_type_id, -555), x, NULL, st);
      ENT_IO.append_to_XML(id_by_brief('T_POLICY_FORM_TYPE')
                          ,NVL(rec_prod.t_policy_form_type_id, -555)
                          ,x
                          ,NULL
                          ,st);
    
      --Функция расчета страховой суммы по договору
      IF rec_prod.ins_amount_func_id IS NOT NULL
      THEN
        x := ENT_IO.exp_prod_coef_type_by_id(rec_prod.ins_amount_func_id, x);
      END IF;
    
      --сам Продукт
      ENT_IO.append_to_XML(id_by_brief('T_PRODUCT'), rec_prod.PRODUCT_ID, x, NULL, st);
    
      --структура Продукта
      FOR rec_prod_ver IN (SELECT * FROM T_PRODUCT_VERSION pv WHERE pv.PRODUCT_ID = rec_prod.product_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_VER_STATUS')
                            ,NVL(rec_prod_ver.version_status, -555)
                            ,x
                            ,NULL
                            ,st);
        ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_VERSION')
                            ,rec_prod_ver.T_PRODUCT_VERSION_ID
                            ,x
                            ,NULL
                            ,st);
      
        --правила по Продукту
        FOR rec_prod_ver_lob IN (SELECT *
                                   FROM T_PRODUCT_VER_LOB pvl
                                  WHERE pvl.product_version_id = rec_prod_ver.t_product_version_id)
        LOOP
          --правило по Продукту
          ENT_IO.append_to_XML(id_by_brief('T_PRODUCT_VER_LOB')
                              ,rec_prod_ver_lob.t_product_ver_lob_id
                              ,x
                              ,NULL
                              ,st);
        
          --линии по Продукту
          FOR rec_prod_line IN (SELECT *
                                  FROM T_PRODUCT_LINE pl
                                 WHERE pl.product_ver_lob_id = rec_prod_ver_lob.t_product_ver_lob_id)
          LOOP
            n := exp_prod_line(rec_prod_line.ID
                              ,p_exp_prod_coef_type_by_id
                              ,p_exp_questionnaire_type
                              ,x);
          END LOOP;
        END LOOP;
      END LOOP;
    
      --Условия встепления в силу
      exp_product_conf_cond(rec_prod.product_id, x);
    
      --Рассторжение
      exp_product_decline(rec_prod.product_id, x);
    
      --Периоды действия
      exp_prod_period(rec_prod.product_id, x);
    
      --Валюта ответственности
      exp_prod_cur(rec_prod.product_id, x);
    
      --Валюта платежа для Продукта
      exp_prod_pay_cur(rec_prod.product_id, x);
    
      --Тип Контакта для Продукта
      exp_prod_cont_type(rec_prod.product_id, x);
    
      --Каналы продаж по Продукту
      exp_prod_sales_chan(rec_prod.product_id, x);
    
      --Платежи по Продукту
      exp_prod_pay_terms(rec_prod.product_id, x);
    
      --Выплаты по Продукту
      exp_prod_claim_payterm(rec_prod.product_id, x);
    
      --Документы для получения выплаты
      exp_prod_issuer_doc(rec_prod.product_id, x);
    
      --Отчёты
      exp_rep_product(rec_prod.product_id, x);
    
      --Типы доп.соглашений
      exp_prod_addendum(rec_prod.product_id, x);
    
      --порядок выплаты
      exp_prod_pay_ord(rec_prod.product_id, x);
    
      --Типы БСО
      exp_prod_bso_type(rec_prod.product_id, x);
    
    END LOOP;
  
    ENT_IO.close_xml(x);
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_prod_coef_type_by_id
  (
    p_prod_coef_type_id NUMBER
   ,p_tmp_xml_id        NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    x  NUMBER;
    st VARCHAR2(1000);
  BEGIN
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.open_xml(x);
    ELSE
      x := p_tmp_xml_id;
    END IF;
  
    --Функция
    FOR cur_prod_coef_type IN (SELECT *
                                 FROM T_PROD_COEF_TYPE pct
                                WHERE pct.T_PROD_COEF_TYPE_ID = p_prod_coef_type_id)
    LOOP
      --грузим суб-Функцию
      IF cur_prod_coef_type.sub_t_prod_coef_type_id IS NOT NULL
      THEN
        x := ENT_IO.exp_prod_coef_type_by_id(cur_prod_coef_type.sub_t_prod_coef_type_id, x);
      END IF;
    
      --Аттрибуты
      FOR cur_attribut IN (SELECT *
                             FROM T_ATTRIBUT a
                            WHERE a.T_ATTRIBUT_ID IN (cur_prod_coef_type.factor_1
                                                     ,cur_prod_coef_type.factor_2
                                                     ,cur_prod_coef_type.factor_3
                                                     ,cur_prod_coef_type.factor_4
                                                     ,cur_prod_coef_type.factor_5
                                                     ,cur_prod_coef_type.factor_6
                                                     ,cur_prod_coef_type.factor_7
                                                     ,cur_prod_coef_type.factor_8
                                                     ,cur_prod_coef_type.factor_9
                                                     ,cur_prod_coef_type.factor_10))
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_ATTRIBUT_SOURCE')
                            ,NVL(cur_attribut.t_attribut_source_id, -555)
                            ,x
                            ,NULL
                            ,st);
        ENT_IO.append_to_XML(id_by_brief('T_ATTRIBUT'), cur_attribut.t_attribut_id, x, NULL, st);
        FOR cur_attr_ent IN (SELECT *
                               FROM T_ATTRIBUT_ENTITY ae
                              WHERE ae.T_ATTRIBUT_ID = cur_attribut.t_attribut_id)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_ATTRIBUT_ENTITY')
                              ,cur_attr_ent.t_attribut_entity_id
                              ,x
                              ,NULL
                              ,st);
        END LOOP;
      END LOOP;
    
      --Правило сравнения
      FOR cur_prod_coef_comp IN (SELECT *
                                   FROM T_PROD_COEF_COMP pcc
                                  WHERE pcc.T_PROD_COEF_COMP_ID IN
                                        (cur_prod_coef_type.comparator_1
                                        ,cur_prod_coef_type.comparator_2
                                        ,cur_prod_coef_type.comparator_3
                                        ,cur_prod_coef_type.comparator_4
                                        ,cur_prod_coef_type.comparator_5
                                        ,cur_prod_coef_type.comparator_6
                                        ,cur_prod_coef_type.comparator_7
                                        ,cur_prod_coef_type.comparator_8
                                        ,cur_prod_coef_type.comparator_9
                                        ,cur_prod_coef_type.comparator_10))
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_COMP')
                            ,cur_prod_coef_comp.t_prod_coef_comp_id
                            ,x
                            ,NULL
                            ,st);
      END LOOP;
    
      ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TARIFF')
                          ,NVL(cur_prod_coef_type.t_prod_coef_tariff_id, -555)
                          ,x
                          ,NULL
                          ,st);
      ENT_IO.append_to_XML(id_by_brief('FUNC_DEFINE_TYPE')
                          ,NVL(cur_prod_coef_type.func_define_type_id, -555)
                          ,x
                          ,NULL
                          ,st);
      ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF_TYPE')
                          ,cur_prod_coef_type.t_prod_coef_type_id
                          ,x
                          ,NULL
                          ,st);
    
      -- Таблица значений Функции
      FOR cur_prod_coef IN (SELECT *
                              FROM T_PROD_COEF pc
                             WHERE pc.T_PROD_COEF_TYPE_ID = cur_prod_coef_type.t_prod_coef_type_id)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('T_PROD_COEF'), cur_prod_coef.t_prod_coef_id, x, NULL, st);
      END LOOP;
    END LOOP;
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_questionnaire_type_by_id
  (
    p_questionnaire_type_id NUMBER
   ,p_tmp_xml_id            NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    x  NUMBER;
    st VARCHAR2(1000);
  BEGIN
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.open_xml(x);
    ELSE
      x := p_tmp_xml_id;
    END IF;
  
    --Анкета
    FOR cur_questionnaire_type IN (SELECT *
                                     FROM QUESTIONNAIRE_TYPE qt
                                    WHERE qt.QUESTIONNAIRE_TYPE_ID = p_questionnaire_type_id)
    LOOP
      ENT_IO.append_to_XML(id_by_brief('QUESTIONNAIRE_TYPE')
                          ,cur_questionnaire_type.QUESTIONNAIRE_TYPE_ID
                          ,x
                          ,NULL
                          ,st);
    
      --Вопросы Анкеты
      FOR cur_question IN (SELECT *
                             FROM QUESTION q
                            WHERE q.QUESTIONNAIRE_TYPE_ID =
                                  cur_questionnaire_type.QUESTIONNAIRE_TYPE_ID)
      LOOP
        ENT_IO.append_to_XML(id_by_brief('QUESTION'), cur_question.question_id, x, NULL, st);
      
        --Ответы Анкеты
        FOR cur_question_answer IN (SELECT *
                                      FROM T_QUESTION_ANSWER qa
                                     WHERE qa.QUESTION_ID = cur_question.question_id)
        LOOP
          ENT_IO.append_to_XML(id_by_brief('T_QUESTION_ANSWER')
                              ,cur_question_answer.t_question_answer_id
                              ,x
                              ,NULL
                              ,st);
        END LOOP;
      END LOOP;
    END LOOP;
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  /*******************************************************************************/

  PROCEDURE exp_ent_settings
  (
    p_ent_id IN NUMBER
   ,p_exp_id IN NUMBER
  ) IS
    str VARCHAR2(32000);
  BEGIN
    FOR cur_entity IN (SELECT * FROM ENTITY e WHERE e.ENT_ID = p_ent_id)
    LOOP
      IF cur_entity.parent_id IS NOT NULL
      THEN
        exp_ent_settings(cur_entity.parent_id, p_exp_id);
      END IF;
      --выгружаем метаданные сущности
      str := '  <meta brief=''' || brief_by_id(cur_entity.ent_id) || ''' obj_name="' ||
             cur_entity.obj_name || '" is_audit="' || cur_entity.is_audit || '" is_filial="' ||
             cur_entity.is_filial || '" is_gate="' || cur_entity.is_gate || '">';
      --'" is_guid="'||cur_entity.is_guid||'">';
      insert_txt(str);
    
      --выгружаем настройки Аттрибутов
      FOR cur_attr IN (SELECT a.BRIEF
                             ,AT.brief   AS TYPE
                             ,a.IS_TRANS
                             ,a.IS_KEY
                             ,e.BRIEF    AS ref_ent_brief
                             ,a.IS_EXCL
                         FROM attr a
                         JOIN attr_type AT
                           ON AT.ATTR_TYPE_ID = a.ATTR_TYPE_ID
                          AND AT.BRIEF NOT IN ('C', 'OI', 'OE', 'OF')
                         LEFT JOIN entity e
                           ON a.REF_ENT_ID = e.ENT_ID
                        WHERE a.ent_id = cur_entity.ent_id)
      LOOP
        str := '    <attr brief=''' || cur_attr.brief || ''' type=''' || cur_attr.TYPE ||
               ''' is_trans="' || cur_attr.is_trans || '" is_key="' || cur_attr.is_key ||
               '" ref_ent_brief="' || cur_attr.ref_ent_brief || '" is_excl="' || cur_attr.is_excl ||
               '"/>';
        insert_txt(str);
      END LOOP;
      insert_txt('  </meta>');
    END LOOP;
  END;

  /*******************************************************************************/

  PROCEDURE exp_ent_settings
  (
    p_ent_brief IN VARCHAR2
   ,p_exp_id    IN NUMBER
  ) IS
  BEGIN
    exp_ent_settings(id_by_brief(p_ent_brief), p_exp_id);
  END;

  /*******************************************************************************/

  PROCEDURE exp_list_ent_settings
  (
    p_ents_brief IN VARCHAR2
   ,p_exp_id     IN NUMBER
  ) IS
    str       VARCHAR2(32000);
    ent_brief VARCHAR2(32000);
  BEGIN
    str := TRANSLATE(p_ents_brief, ' ''', ' ');
  
    WHILE (str IS NOT NULL)
          AND (LENGTH(str) <> 0)
    LOOP
      IF INSTR(str, ',') = 0
      THEN
        ent_brief := str;
        str       := NULL;
      ELSE
        ent_brief := TRIM(SUBSTR(str, 1, INSTR(str, ',') - 1));
        str       := SUBSTR(str, INSTR(str, ',') + 1);
      END IF;
      exp_ent_settings(ent_brief, p_exp_id);
    END LOOP;
  END;

  /*******************************************************************************/

  FUNCTION load_ent_settings
  (
    dir     VARCHAR2
   ,inpfile VARCHAR2
   ,errfile VARCHAR2
  ) RETURN NUMBER IS
    p        xmlparser.parser;
    doc      xmldom.DOMDocument;
    is_trace NUMBER := 0;
  
    --парсим xml-файл в иерархической последовательности
    PROCEDURE load_node
    (
      p_ent_id IN NUMBER
     ,p_node   IN xmldom.DOMNode
     ,num_ent  IN NUMBER
    ) IS
      rec_attr   attr%ROWTYPE;
      n_parent   xmldom.DOMNode;
      n_child    xmldom.DOMNode;
      len        NUMBER;
      child_num  NUMBER := 0;
      node_map   xmldom.DOMNamedNodeMap;
      child_val  VARCHAR(32000);
      child_name VARCHAR(32000);
    BEGIN
      n_parent := xmldom.GETFIRSTCHILD(p_node);
    
      WHILE n_parent.ID != -1
      LOOP
        node_map := xmldom.GETATTRIBUTES(n_parent);
        IF (xmldom.isNull(node_map) = FALSE)
        THEN
          len := xmldom.getLength(node_map);
        
          --трассировка
          IF is_trace = 1
          THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10) || UPPER(xmldom.getNodeName(n_parent)));
            DBMS_OUTPUT.PUT_LINE('');
          END IF;
        
          rec_attr := NULL;
          FOR i IN 0 .. len - 1
          LOOP
            n_child := xmldom.ITEM(node_map, i);
          
            --трассировка
            IF is_trace = 1
            THEN
              DBMS_OUTPUT.PUT_LINE(UPPER(xmldom.getNodeName(n_child)) || '=' ||
                                   xmldom.getNodeValue(n_child));
            END IF;
          
            child_name := xmldom.getNodeName(n_child);
            child_val  := xmldom.getNodeValue(n_child);
            CASE UPPER(child_name)
              WHEN 'BRIEF' THEN
                rec_attr.brief := UPPER(child_val);
              WHEN 'TYPE' THEN
                BEGIN
                  SELECT AT.ATTR_TYPE_ID
                    INTO rec_attr.attr_type_id
                    FROM attr_type AT
                   WHERE AT.BRIEF = child_val;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    set_err_txt('Ошибка загрузки настроек аттрибутов сущности. Встретился неизвестный Тип Аттрибута ' ||
                                child_val);
                END;
              WHEN 'IS_TRANS' THEN
                rec_attr.is_trans := TO_NUMBER(child_val);
              WHEN 'IS_KEY' THEN
                rec_attr.is_key := TO_NUMBER(child_val);
              WHEN 'REF_ENT_BRIEF' THEN
                rec_attr.ref_ent_id := id_by_brief(UPPER(child_val));
                IF UPPER(child_val) IS NOT NULL
                   AND rec_attr.ref_ent_id IS NULL
                THEN
                  set_err_txt('Ошибка загрузки настроек аттрибутов сущности. Не найдена Сущность с именем ' ||
                              UPPER(child_val) || '.' || CHR(10) ||
                              'Требуется обновление структуры БД');
                END IF;
              WHEN 'IS_EXCL' THEN
                rec_attr.is_excl := TO_NUMBER(child_val);
              ELSE
                set_err_txt('Ошибка при загрузке настроек аттрибутов сущности. Встретился неизвестный аттрибут из ATTR: ' ||
                            UPPER(xmldom.getNodeName(n_child)));
            END CASE;
          END LOOP;
        
          BEGIN
            UPDATE attr a
               SET a.ATTR_TYPE_ID = rec_attr.attr_type_id
                  ,a.IS_TRANS     = rec_attr.is_trans
                  ,a.IS_KEY       = rec_attr.is_key
                  ,a.REF_ENT_ID   = rec_attr.ref_ent_id
                  ,a.IS_EXCL      = rec_attr.is_excl
             WHERE a.ENT_ID = p_ent_id
               AND a.BRIEF = rec_attr.brief;
          
            IF SQL%NOTFOUND
            THEN
              IF rec_attr.is_excl = 0
              THEN
                set_err_txt('Ошибка при загрузке настроек аттрибутов сущности. Встретился неизвестный аттрибут ' ||
                            rec_attr.brief || ' для сущности ' || brief_by_id(p_ent_id) ||
                            '. Обновите структуру БД');
              END IF;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              set_err_txt('Ошибка загрузки настроек аттрибутов сущности ' || brief_by_id(p_ent_id) ||
                          CHR(10) || 'Ошибка при выполнении команды:' || CHR(10) ||
                          'update attr a set a.ATTR_TYPE_ID = ' || rec_attr.attr_type_id ||
                          ', a.IS_TRANS = ' || rec_attr.is_trans || ', a.IS_KEY = ' ||
                          rec_attr.is_key || ', a.REF_ENT_ID = ' || NVL(rec_attr.ref_ent_id, 'NULL') ||
                          ', a.IS_EXCL = ' || rec_attr.is_excl || ' where a.ENT_ID = ' || p_ent_id ||
                          ' and a.BRIEF = ''' || rec_attr.brief || '''' || CHR(10) || SQLERRM);
          END;
        
        END IF;
        n_parent  := xmldom.GETNEXTSIBLING(n_parent);
        child_num := child_num + 1;
      END LOOP;
    END;
  
    --парсим xml-файл по отдельным сущностям
    PROCEDURE load_data(doc xmldom.DOMDocument) IS
      rec_entity entity%ROWTYPE;
      --attrval  varchar2(100);
      node_lst   xmldom.DOMNodeList;
      cur_node   xmldom.DOMNode;
      nnm        xmldom.DOMNamedNodeMap;
      len        NUMBER;
      n_child    xmldom.DOMNode;
      child_val  VARCHAR(32000);
      child_name VARCHAR(32000);
      num_ent    NUMBER := 0;
    BEGIN
    
      -- получаем список тегов
      node_lst := xmldom.getElementsByTagName(doc, '*');
      cur_node := xmldom.item(node_lst, 1);
    
      --трассировка
      IF is_trace = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Begin');
      END IF;
    
      --пробегаем по загружаемым сущностям
      WHILE cur_node.ID != -1
      LOOP
        nnm     := xmldom.GETATTRIBUTES(cur_node);
        num_ent := num_ent + 1;
      
        --обновляем ENTITY
        IF (xmldom.isNull(nnm) = FALSE)
        THEN
          len        := xmldom.getLength(nnm);
          rec_entity := NULL;
          --is_val_tag := false;
          FOR i IN 0 .. len - 1
          LOOP
            n_child := xmldom.ITEM(nnm, i);
          
            --трассировка
            IF is_trace = 1
            THEN
              DBMS_OUTPUT.PUT_LINE(UPPER(xmldom.getNodeName(n_child)) || '=' ||
                                   xmldom.getNodeValue(n_child));
            END IF;
          
            child_name := xmldom.getNodeName(n_child);
            child_val  := xmldom.getNodeValue(n_child);
            CASE UPPER(child_name)
              WHEN 'BRIEF' THEN
                rec_entity.brief  := UPPER(child_val);
                rec_entity.ent_id := id_by_brief(rec_entity.brief);
                IF rec_entity.ent_id IS NULL
                THEN
                  set_err_txt('Ошибка при загрузке метаданных сущности ' || rec_entity.brief ||
                              '. Сущность не найдена!');
                END IF;
              WHEN 'OBJ_NAME' THEN
                rec_entity.obj_name := child_val;
              WHEN 'IS_AUDIT' THEN
                rec_entity.is_audit := child_val;
              WHEN 'IS_FILIAL' THEN
                rec_entity.is_filial := TO_NUMBER(child_val);
              WHEN 'IS_GATE' THEN
                rec_entity.is_gate := TO_NUMBER(child_val);
                --when 'IS_GUID'
            --then rec_entity.is_guid := to_number(child_val);
              ELSE
                set_err_txt('Ошибка при загрузке метажанных сущности ' || rec_entity.brief || CHR(10) ||
                            'Встретился неизвестный аттрибут из таблицы ENTITY: ' || child_name);
            END CASE;
          END LOOP;
        
          BEGIN
            UPDATE entity e
               SET e.OBJ_NAME  = rec_entity.obj_name
                  ,e.IS_AUDIT  = rec_entity.is_audit
                  ,e.IS_FILIAL = rec_entity.is_filial
                  ,e.IS_GATE   = rec_entity.is_gate
            --e.IS_GUID = rec_entity.is_guid
             WHERE e.ENT_ID = rec_entity.ent_id;
          EXCEPTION
            WHEN OTHERS THEN
              set_err_txt('Ошибка при загрузке метаданных Сущности ' || rec_entity.brief || CHR(10) ||
                          'Ошибка при выполнении команды:' || CHR(10) ||
                          'update entity e set e.OBJ_NAME = ' || NVL(rec_entity.obj_name, 'NULL') ||
                          ', e.IS_AUDIT = ' || rec_entity.is_audit || ', e.IS_FILIAL = ' ||
                          rec_entity.is_filial || ', e.IS_GATE = ' || NVL(rec_entity.is_gate, 'NULL') ||
                          --          ', e.IS_GUID = '||rec_entity.is_guid||
                          ' where e.ENT_ID = ' || rec_entity.ent_id);
          END;
        
          --пока не генерим, ввиду отказа от переноса IS_GUID
          /*begin
            ents.gen_ent_all(rec_entity.ent_id);
          exception
            when others
            then set_err_txt('Ошибка при генерации Сущности '||rec_entity.brief||chr(10)||'Ошибка при выполнении команды:'||chr(10)||
                             'ents.gen_ent_all('||rec_entity.ent_id||')');
          end;*/
        END IF;
      
        --attrval := upper(xmldom.getNodeValue(xmldom.item(nnm,0)));
        --dbms_output.put_line(chr(10)||attrval);
        load_node(rec_entity.ent_id, cur_node, num_ent);
        cur_node := xmldom.GETNEXTSIBLING(cur_node);
      END LOOP;
    
      --трассировка
      IF is_trace = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('End');
      END IF;
    
    END;
  
  BEGIN
  
    --создаём новый парсер
    p := xmlparser.newParser;
  
    IF xml_file IS NOT NULL
    THEN
      xmlparser.PARSECLOB(p, xml_file);
    ELSE
      IF dir IS NOT NULL
         AND inpfile IS NOT NULL
      THEN
      
        --начальные настройки
        xmlparser.setValidationMode(p, FALSE);
        xmlparser.setErrorLog(p, dir || '/' || errfile);
        xmlparser.setBaseDir(p, dir);
      
        --парсим xml-файл
        xmlparser.parse(p, dir || '/' || inpfile);
      END IF;
    END IF;
  
    --получаем ссылку на документ
    doc := xmlparser.getDocument(p);
  
    --выполняем загрузку Объектов сущности
    load_data(doc);
    COMMIT;
    RETURN 1;
  
  EXCEPTION
    WHEN xmldom.INDEX_SIZE_ERR THEN
      RAISE_APPLICATION_ERROR(-20120, 'Index Size error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.DOMSTRING_SIZE_ERR THEN
      RAISE_APPLICATION_ERROR(-20121, 'String Size error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.HIERARCHY_REQUEST_ERR THEN
      RAISE_APPLICATION_ERROR(-20122, 'Hierarchy request error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.WRONG_DOCUMENT_ERR THEN
      RAISE_APPLICATION_ERROR(-20123, 'Wrong doc error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.INVALID_CHARACTER_ERR THEN
      RAISE_APPLICATION_ERROR(-20124, 'Invalid Char error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NO_DATA_ALLOWED_ERR THEN
      RAISE_APPLICATION_ERROR(-20125, 'Nod data allowed error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NO_MODIFICATION_ALLOWED_ERR THEN
      RAISE_APPLICATION_ERROR(-20126, 'No mod allowed error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NOT_FOUND_ERR THEN
      RAISE_APPLICATION_ERROR(-20127, 'Not found error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.NOT_SUPPORTED_ERR THEN
      RAISE_APPLICATION_ERROR(-20128, 'Not supported error');
      ROLLBACK;
      RETURN 0;
    
    WHEN xmldom.INUSE_ATTRIBUTE_ERR THEN
      RAISE_APPLICATION_ERROR(-20129, 'In use attr error');
      ROLLBACK;
      RETURN 0;
    
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  /*******************************************************************************/

  FUNCTION exp_prod_ent_settings
  (
    p_tmp_xml_id                NUMBER DEFAULT NULL
   ,p_exp_prod_coef_typ_ent_set NUMBER DEFAULT 1
   ,p_quest_type_ent_set        NUMBER DEFAULT 1
  ) RETURN NUMBER IS
    x NUMBER;
  BEGIN
    ENT_IO.open_xml(x);
    ENT_IO.exp_list_ent_settings('T_INSURANCE_GROUP,T_LOB,T_LOB_LINE,BSO_TYPE,T_POLICY_FORM_TYPE,T_PRODUCT,T_PRODUCT_VER_STATUS,T_PRODUCT_VERSION,T_PRODUCT_VER_LOB'
                                ,x);
    --SOURCE IN ('T_INSURANCE_GROUP','T_LOB','T_LOB_LINE','BSO_TYPE','T_POLICY_FORM_TYPE','T_PRODUCT','T_PRODUCT_VER_STATUS','T_PRODUCT_VERSION','T_PRODUCT_VER_LOB')
  
    ENT_IO.exp_list_ent_settings('T_PRODUCT_PERIOD,T_PERIOD,T_PERIOD_USE_TYPE,T_PROD_CURRENCY,FUND,T_PROD_PAY_CURR,T_PRODUCT_CONT_TYPE,T_CONTACT_TYPE'
                                ,x);
    --SOURCE IN ('T_PRODUCT_PERIOD','T_PERIOD','T_PERIOD_USE_TYPE','T_PROD_CURRENCY','FUND','T_PROD_PAY_CURR','T_PRODUCT_CONT_TYPE','T_CONTACT_TYPE')
  
    ENT_IO.exp_list_ent_settings('T_PROD_SALES_CHAN,T_SALES_CHANNEL,T_PROD_PAYMENT_TERMS,T_PAYMENT_TERMS,T_PAY_TERM_DETAILS,T_COLLECTION_METHOD,T_PROD_CLAIM_PAYTERM,T_PROD_ISSUER_DOC,T_ISSUER_DOC_TYPE,REP_PRODUCT,REP_REPORT,REP_TYPE,REP_KIND,T_PRODUCT_ADDENDUM,T_ADDENDUM_TYPE,T_PROD_PAYMENT_ORDER,T_PAYMENT_ORDER,T_PRODUCT_BSO_TYPES'
                                ,x);
    --SOURCE IN ('T_PROD_SALES_CHAN','T_SALES_CHANNEL','T_PROD_PAYMENT_TERMS','T_PAYMENT_TERMS','T_PAY_TERM_DETAILS','T_COLLECTION_METHOD','T_PROD_CLAIM_PAYTERM','T_PROD_ISSUER_DOC','T_ISSUER_DOC_TYPE','REP_PRODUCT','REP_REPORT','REP_TYPE','REP_KIND','T_PRODUCT_ADDENDUM','T_ADDENDUM_TYPE','T_PROD_PAYMENT_ORDER','T_PAYMENT_ORDER','T_PRODUCT_BSO_TYPES')
  
    ENT_IO.exp_list_ent_settings('T_AS_TYPE_PROD_LINE,T_ASSET_TYPE,T_PRODUCT_LINE_TYPE,T_PREMIUM_TYPE,T_ROUND_RULES,T_PRODUCT_LINE,T_PROD_LINE_OPTION,T_PERIL,T_PROD_LINE_OPT_PERIL,T_DAMAGE_CODE,T_PROD_LINE_DAMAGE,T_DEDUCTIBLE_TYPE,T_DEDUCT_VAL_TYPE,T_DEDUCTIBLE_REL,T_PROD_LINE_DEDUCT,T_PROD_LINE_COEF,T_PROD_LINE_FORM,QUESTIONNAIRE_TYPE,T_PROD_LINE_COEF_SAF,SAFETY_RIGHT,SAFETY_RIGHT_TYPE,PARENT_PROD_LINE,CONCURRENT_PROD_LINE'
                                ,x);
    --SOURCE IN ('T_AS_TYPE_PROD_LINE','T_ASSET_TYPE','T_PRODUCT_LINE_TYPE','T_PREMIUM_TYPE','T_ROUND_RULES','T_PRODUCT_LINE','T_PROD_LINE_OPTION','T_PERIL','T_PROD_LINE_OPT_PERIL','T_DAMAGE_CODE','T_PROD_LINE_DAMAGE','T_DEDUCTIBLE_TYPE','T_DEDUCT_VAL_TYPE','T_DEDUCTIBLE_REL','T_PROD_LINE_DEDUCT','T_PROD_LINE_COEF','T_PROD_LINE_COEF_SAF','SAFETY_RIGHT','SAFETY_RIGHT_TYPE','QUESTIONNAIRE_TYPE','T_PROD_LINE_FORM','PARENT_PROD_LINE','CONCURRENT_PROD_LINE')
  
    ENT_IO.exp_list_ent_settings('T_PRODUCT_CONF_COND,T_CONFIRM_CONDITION,T_PRODUCT_DECLINE,T_DECLINE_REASON,T_DECLINE_PARTY,T_DECLINE_TYPE,T_PROD_CLAIM_CONTROL'
                                ,x);
    --SOURCE IN ('T_PRODUCT_CONF_COND','T_CONFIRM_CONDITION','T_PRODUCT_DECLINE','T_DECLINE_REASON','T_DECLINE_PARTY','T_DECLINE_TYPE','T_PROD_CLAIM_CONTROL')
  
    --настройки Функций
    IF p_exp_prod_coef_typ_ent_set = 1
    THEN
      x := ENT_IO.exp_prod_coef_typ_ent_settings(x);
    END IF;
  
    --настройки Анкет
    IF p_quest_type_ent_set = 1
    THEN
      x := ENT_IO.exp_quest_type_ent_settings(x);
    END IF;
  
    ENT_IO.close_xml(x);
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_prod_coef_typ_ent_settings(p_tmp_xml_id NUMBER DEFAULT NULL) RETURN NUMBER IS
    x NUMBER;
  BEGIN
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.open_xml(x);
    ELSE
      x := p_tmp_xml_id;
    END IF;
  
    ENT_IO.exp_list_ent_settings('T_PROD_COEF_TYPE,T_ATTRIBUT,T_ATTRIBUT_SOURCE,T_PROD_COEF_COMP,T_PROD_COEF_TYPE,T_PROD_COEF_TARIFF,FUNC_DEFINE_TYPE,T_PROD_COEF'
                                ,x);
    --SOURCE IN ('T_PROD_COEF_TYPE','T_ATTRIBUT','T_ATTRIBUT_SOURCE','T_PROD_COEF_COMP','T_PROD_COEF_TYPE','T_PROD_COEF_TARIFF','FUNC_DEFINE_TYPE','T_PROD_COEF')
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_app_param_ent_settings(p_tmp_xml_id NUMBER DEFAULT NULL) RETURN NUMBER IS
    x NUMBER;
  BEGIN
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.open_xml(x);
    ELSE
      x := p_tmp_xml_id;
    END IF;
  
    ENT_IO.exp_list_ent_settings('APP_PARAM,UREF,APP_PARAM_GROUP,APP_PARAM_VAL', x);
    --SOURCE IN ('APP_PARAM','UREF','APP_PARAM_GROUP','APP_PARAM_VAL')
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_quest_type_ent_settings(p_tmp_xml_id NUMBER DEFAULT NULL) RETURN NUMBER IS
    x NUMBER;
  BEGIN
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.open_xml(x);
    ELSE
      x := p_tmp_xml_id;
    END IF;
  
    ENT_IO.exp_list_ent_settings('QUESTION,QUESTIONNAIRE_TYPE,T_QUESTION_ANSWER', x);
    --SOURCE IN ('QUESTION','QUESTIONNAIRE_TYPE','T_QUESTION_ANSWER')
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  /*******************************************************************************/

  FUNCTION exp_app_param_by_id
  (
    p_app_param_id NUMBER
   ,p_tmp_xml_id   NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    x  NUMBER;
    st VARCHAR2(1000);
  BEGIN
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.open_xml(x);
    ELSE
      x := p_tmp_xml_id;
    END IF;
  
    --Настройка приложения
    FOR cur_app_param IN (SELECT * FROM APP_PARAM ap WHERE ap.APP_PARAM_ID = p_app_param_id)
    LOOP
      --Группа настройки
      ENT_IO.append_to_XML(id_by_brief('APP_PARAM_GROUP')
                          ,NVL(cur_app_param.app_param_group_id, -555)
                          ,x
                          ,NULL
                          ,st);
      --UREF
      ------
      ENT_IO.append_to_XML(id_by_brief('APP_PARAM'), cur_app_param.app_param_id, x, NULL, st);
    
      FOR cur_app_param_val IN (SELECT *
                                  FROM APP_PARAM_VAL apv
                                 WHERE apv.APP_PARAM_ID = cur_app_param.app_param_id)
      LOOP
        --UREF
        ------
        ENT_IO.append_to_XML(id_by_brief('APP_PARAM_VAL')
                            ,cur_app_param_val.app_param_val_id
                            ,x
                            ,NULL
                            ,st);
      END LOOP;
    END LOOP;
  
    IF p_tmp_xml_id IS NULL
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
    RETURN x;
  END;

  PROCEDURE init_clob IS
  BEGIN
    xml_file := NULL;
  END;

  PROCEDURE add_clob(p_str VARCHAR2) IS
  BEGIN
    xml_file := xml_file || p_str;
  END;

END ENT_IO;
/

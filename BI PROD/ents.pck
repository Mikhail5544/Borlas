CREATE OR REPLACE PACKAGE ents IS

  /**
  * Пакет обслуживания технологии разработки
  * @author Alexander Kalabukhov
  * @version 2.12
  */

  /*
    Пересоздание триггера ins.che_document  
  */
  PROCEDURE create_che_document_trg;

  /**
  * ИД филиала, под которым работает пользователь
  */
  filial_id NUMBER(6);
  /**
  * Язык системы
  */
  sys_lang_id NUMBER(3) := 1;
  /**
  * Язык, под которым работает пользователь
  */
  lang_id NUMBER(3) := sys_lang_id;
  /**
  * Схема в которой работает система
  */
  v_sch VARCHAR2(30) := 'INS';
  /**
  * Схема для разработки, в которую входят из Oracle Forms
  */
  dev_owner VARCHAR2(30) := 'INSD';

  client_id CONSTANT NUMBER(2) := pkg_app_param.get_app_param_n('CLIENTID');

  /**
  * Вернуть флаг защиты от сбора данных (роботов) для текущего юзера (1/0)
  */
  FUNCTION get_safety_flag RETURN NUMBER;
  /**
  * Сброс счетчика безопасности (автономная транзакция)
  */
  PROCEDURE reset_safety_counter;
  /**
  * Инкремент счетчика безопасности (автономная транзакция)
  */
  PROCEDURE inc_safety_counter;
  /**
  * Максимальное значение счетчика
  */
  FUNCTION get_safety_max_counter RETURN NUMBER;
  /**
  * Максимальное количество попыток ввести код
  */
  FUNCTION get_safety_max_tries RETURN NUMBER;
  /**
  * Количество картинок с кодом (в таблице safety_pictures)
  */
  FUNCTION get_safety_pictures_count RETURN NUMBER;

  FUNCTION get_lang_id RETURN NUMBER;

  FUNCTION get_sys_lang_id RETURN NUMBER;

  -- получить родительскую сущность
  FUNCTION get_parent_ent(p_ent_id IN NUMBER) RETURN entity%ROWTYPE;

  -- получить название ИД поля сущности
  FUNCTION get_ent_pk(p_ent_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Генерация объектов сущности в БД для всех сущностей или для ветки с указанным родителем
  * @author Alexander Kalabukhov
  * @p_ent_brief Сокращение сущности
  */
  PROCEDURE gen_ent_all
  (
    p_ent_brief VARCHAR2
   ,p_cascade   NUMBER DEFAULT 1
  );

  /**
  * Генерация объектов сущности в БД для всех сущностей или для ветки с указанным родителем
  * @author Alexander Kalabukhov
  * @p_ent_id number ИД сущности
  */
  PROCEDURE gen_ent_all
  (
    p_ent_id  NUMBER DEFAULT NULL
   ,p_cascade NUMBER DEFAULT 1
  );

  /**
  * Генерация функций по объекту (obj_name, obj_del, obj_lock и т.п.)
  * @author Alexander Kalabukhov
  */
  PROCEDURE gen_obj_all;

  /**
  * Генерация синонимов для пользователей системы
  * @author Alexander Kalabukhov
  * @p_user in varchar2 Наименование пользователя БД
  */
  PROCEDURE gen_user_syn(p_user IN VARCHAR2 DEFAULT NULL);

  /**
  * Генерация функции, вычисляющецй наименование объекта
  * @author Alexander Kalabukhov
  */
  PROCEDURE gen_obj_name AS
    LANGUAGE JAVA NAME 'ents.gen_obj_name()';

  /**
  * Генерация процедуры, удаляющей объект сущности
  * @author Alexander Kalabukhov
  */
  PROCEDURE gen_obj_del AS
    LANGUAGE JAVA NAME 'ents.gen_obj_del()';

  /**
  * Генерация процедуры, блокирующий объект сущности
  * @author Alexander Kalabukhov
  */
  PROCEDURE gen_obj_lock AS
    LANGUAGE JAVA NAME 'ents.gen_obj_lock()';

  /**
  * Генерация процедуры, возвращающей список объектов по сущности
  * @author Alexander Kalabukhov
  */
  PROCEDURE gen_obj_list AS
    LANGUAGE JAVA NAME 'ents.gen_obj_list()';

  /**
  * Генерация триггера для сущностей
  * @author Alexander Kalabukhov
  */
  PROCEDURE gen_ent_tr;

  /**
  * Генерация триггера для сущностей
  * @author Alexander Kalabukhov
  * @p_ent_id number ИД сущности
  */
  PROCEDURE gen_ent_tr(p_ent_id IN NUMBER) AS
    LANGUAGE JAVA NAME 'ents.gen_ent_tr(int)';

  /**
  * Сгенерить синоним для VIEW сущности в схеме dev_owner
  */
  PROCEDURE gen_ent_dev_synonym
  (
    p_ent_id    IN NUMBER DEFAULT NULL
   ,p_ent_brief IN VARCHAR2 DEFAULT NULL
  );
  /**
  * Удаление триггера для сущностей
  * @author Alexander Kalabukhov
  * @p_ent_id number ИД сущности
  */
  PROCEDURE drop_ent_tr(p_ent_id IN NUMBER);

  /**
  * Создание сущности
  * @author Alexander Kalabukhov
  * @p_source       Источник данных сущности (наименование таблицы)
  * @p_name         Наименование сущности
  * @p_brief        Сокращение сущности
  * @p_parent_brief Сокращение родительской сущности
  */
  PROCEDURE create_ent
  (
    p_source       IN VARCHAR2
   ,p_name         IN VARCHAR2
   ,p_brief        IN VARCHAR2
   ,p_parent_brief IN VARCHAR2 DEFAULT NULL
  );

  /**
  * Генерация таблицы и прочих объектов сущности в БД
  * @author Alexander Kalabukhov
  * @p_ent_id number ИД сущности
  */
  PROCEDURE gen_ent_src(p_ent_id IN NUMBER);

  /**
  * Генерация атрибутов сущности
  * @author Alexander Kalabukhov
  * @p_ent_id number ИД сущности
  */
  PROCEDURE gen_attr(p_ent_id IN NUMBER);

  -- Зарегистрировать объект на который сослались
  PROCEDURE uref_ins
  (
    p_ent_id NUMBER
   , -- ИД сущности объекта, на которого сослались
    p_obj_id NUMBER -- ИД объекта
  );

  -- Удалить регистрацию объекта на который сослались
  PROCEDURE uref_del
  (
    p_ent_id NUMBER
   , -- ИД сущности объекта, на которого сослались
    p_obj_id NUMBER -- ИД объекта
  );

  -- Удалить регистрацию объектов, на которые уже нет ссылок
  PROCEDURE uref_clean;

  -- Генерация проверки для поля ure_id таблицы UREF
  PROCEDURE gen_uref_check;

  -- Вычисляет название универсальной ссылки, обрезая окончание поля
  FUNCTION uref_col_name(p_name VARCHAR2 -- Наименования поля
                         ) RETURN VARCHAR2;

  -- Вычисляет название из описания
  FUNCTION name_from_descr(p_descr VARCHAR2) RETURN VARCHAR2;

  -- Вычисляет комментарий из описания
  FUNCTION note_from_descr(p_descr VARCHAR2) RETURN VARCHAR2;

  -- Возвращает атрибуты сущности из БД
  FUNCTION attr_db(p_ent_id NUMBER) RETURN tt_ent_db_attr;

  -- Заполняет все пустые наименования объекта выборкой из поля NAME, при условии что оно существует
  PROCEDURE fill_obj_name_as_name;

  -- установить текущее приложение
  PROCEDURE set_schema(p_schema IN VARCHAR2);

  -- получить текущее приложение
  FUNCTION get_schema RETURN VARCHAR2;

  -- выдача грантов от одной схемы к другой (ссылки, выборка, обновление, добавление, удаление)
  -- procedure grant_from_to(p_from varchar2, p_to varchar2);

  FUNCTION trunc_name
  (
    p_val IN VARCHAR2
   ,p_len IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION col_def_val
  (
    p_tab IN VARCHAR2
   ,p_col IN VARCHAR2
  ) RETURN VARCHAR2;

  PROCEDURE set_null_def
  (
    p_tab IN VARCHAR2
   ,p_col IN VARCHAR2
  );

  PROCEDURE code_create_obj(p_ent_brief VARCHAR2);

  PROCEDURE code_create_obj(p_ent_id NUMBER);

  FUNCTION trans_err
  (
    p_num    IN VARCHAR2
   ,p_err    IN VARCHAR2
   ,p_ent_id IN NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;

  PROCEDURE prepare_ve_error;

  FUNCTION check_name
  (
    p_name   IN VARCHAR2
   ,p_prefix IN VARCHAR2
   ,p_table  IN VARCHAR2
  ) RETURN NUMBER;

  FUNCTION get_filial_id RETURN NUMBER;

  PROCEDURE trans_ins
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_val     IN VARCHAR2
   ,p_brief   IN VARCHAR
  );
  PROCEDURE trans_upd
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_val     IN VARCHAR2
   ,p_brief   IN VARCHAR
  );
  PROCEDURE trans_del
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
  );

  PROCEDURE gen_ent_ven(p_ent_id IN NUMBER);

  /**
  * Обновляет временные таблицы, заполеяемые из системных представлений
  * @author Alexander Kalabukhov
  * @p_obj сокращенное наименование представления
  */
  PROCEDURE upd_tmp(p_obj IN VARCHAR2);

  PROCEDURE attr_name_to_descr;

  /**
  * Переименовывает объекты БД по стандартам наименования
  * @author Alexander Kalabukhov
  */
  PROCEDURE repare_objdb_name;

  /**
  * Получение типа поля
  * @author Protsvetov Evgeniy
  * @p_table_name Имя таблицы
  * @p_column_name Имя столбца
  * return Тип поля
  */
  FUNCTION get_col_type
  (
    p_table_name  VARCHAR2
   ,p_column_name VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION brief_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER;

  /*
     Байтин А.
     Удаление сущности
     Drop: 
          * Таблица
          * Триггер
          * Представление
          * Последовательность
          * Псевдоним
     Delete: entity (из attr удалится каскадно)
  
     par_entity_brief - Сокращенное название сущности
  */
  PROCEDURE del_ent
  (
    par_entity_brief VARCHAR2
   ,par_drop_table   BOOLEAN DEFAULT TRUE
  );
END;
/
CREATE OR REPLACE PACKAGE BODY ents IS

  v#_schema VARCHAR2(30);
  /*
     Байтин А.
     Заменил все литеральные префиксы на константы
  */
  v_sequence CONSTANT VARCHAR2(30) := 'SQ_';
  v_trigger  CONSTANT VARCHAR2(30) := 'TREV_';
  v_primary  CONSTANT VARCHAR2(30) := 'PK_';
  v_foreign  CONSTANT VARCHAR2(30) := 'FK_';
  v_foreigni CONSTANT VARCHAR2(30) := 'FKI_';
  v_view     CONSTANT VARCHAR2(30) := 'VEN_';
  v_unique   CONSTANT VARCHAR2(30) := 'UK_';
  v_check    CONSTANT VARCHAR2(30) := 'CHE_';

  PROCEDURE create_che_document_trg IS
    v_condition         VARCHAR2(4000);
    v_splitted          tt_one_col;
    v_new_entity_exists NUMBER;
    v_ents_array        tt_one_col := tt_one_col();
    v_constraint_exists BOOLEAN := TRUE;
  BEGIN
    BEGIN
      SELECT cs.search_condition
        INTO v_condition
        FROM user_constraints cs
       WHERE cs.constraint_name = 'CHE_DOCUMENT';
    
      v_condition := regexp_replace(v_condition, '[^0-9,]');
      v_splitted  := pkg_utils.get_splitted_string(par_string => v_condition, par_separator => ',');
    
      SELECT COUNT(1)
        INTO v_new_entity_exists
        FROM (SELECT e.ent_id
                                      FROM entity e
                                     START WITH brief = 'DOCUMENT'
              CONNECT BY e.parent_id = PRIOR e.ent_id) all_ents
       WHERE NOT EXISTS (SELECT NULL FROM TABLE(v_splitted) s WHERE s.column_value = all_ents.ent_id);
    
    EXCEPTION
      WHEN no_data_found THEN
        v_constraint_exists := FALSE;
    END;
  
    IF NOT v_constraint_exists
       OR v_new_entity_exists > 0
    THEN
    
      SELECT e.ent_id BULK COLLECT
        INTO v_ents_array
        FROM entity e
       START WITH brief = 'DOCUMENT'
      CONNECT BY e.parent_id = PRIOR e.ent_id
       ORDER BY e.ent_id;
    
      IF v_ents_array.count <> 0
      THEN
        LOCK TABLE document IN SHARE MODE NOWAIT;
        IF v_constraint_exists
        THEN
          EXECUTE IMMEDIATE 'alter table ins.document drop constraint CHE_DOCUMENT';
        END IF;
        EXECUTE IMMEDIATE 'alter table ins.document add constraint CHE_DOCUMENT check (ENT_ID IN (' ||
                          pkg_utils.get_aggregated_string(par_table     => v_ents_array
                                                         ,par_separator => ',') || '))';
      END IF;
    END IF;
  
  END create_che_document_trg;

  FUNCTION id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT e.ent_id FROM entity e WHERE e.brief = p_brief)
    LOOP
      RETURN rc.ent_id;
    END LOOP;
    RETURN NULL;
  END;

  FUNCTION brief_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
    v_result VARCHAR2(30);
  BEGIN
    SELECT e.brief INTO v_result FROM entity e WHERE e.ent_id = p_ent_id;
    RETURN(v_result);
  END;

  FUNCTION get_lang_id RETURN NUMBER IS
  BEGIN
    RETURN ents.lang_id;
  END;

  FUNCTION get_sys_lang_id RETURN NUMBER IS
  BEGIN
    RETURN ents.sys_lang_id;
  END;

  FUNCTION cut2(p_val VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN substr(p_val, 1, length(p_val) - 2);
  END;

  PROCEDURE set_schema(p_schema IN VARCHAR2) IS
    v_schema VARCHAR2(10) := ents.v_sch;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set current_schema = ' || v_schema;
    v#_schema := v_schema;
  END;

  FUNCTION get_schema RETURN VARCHAR2 IS
  BEGIN
    RETURN nvl(v#_schema, ents.v_sch);
  END;

  PROCEDURE raise_msg(p_msg IN VARCHAR2) AS
    n NUMBER;
    j NUMBER;
    i NUMBER;
  BEGIN
    n := length(p_msg);
    IF n <= 255
    THEN
      dbms_output.put_line(p_msg);
    ELSIF n = 0
    THEN
      raise_application_error(-20000, 'Пустое сообщение в функции raise_msg.');
    ELSE
      i := trunc(n / 255);
      IF MOD(n, 255) <> 0
      THEN
        i := i + 1;
      END IF;
      FOR j IN 1 .. i
      LOOP
        dbms_output.put_line(substr(p_msg, 255 * (j - 1) + 1, 255));
      END LOOP;
    END IF;
    --insert into tmp_msg values(p_msg);
    raise_application_error(-20000, p_msg);
  END;

  PROCEDURE exec
  (
    p_sql  IN VARCHAR2
   ,p_msg  IN VARCHAR2
   ,p_excl IN NUMBER DEFAULT NULL
  ) AS
    v_msg VARCHAR2(1000);
  BEGIN
    EXECUTE IMMEDIATE p_sql;
  EXCEPTION
    WHEN OTHERS THEN
      IF (p_excl IS NULL)
         OR (SQLCODE <> p_excl)
      THEN
        v_msg := p_msg || chr(10) || SQLERRM;
        raise_msg(v_msg);
      END IF;
  END;

  -- получить родительскую сущность
  FUNCTION get_parent_ent(p_ent_id IN NUMBER) RETURN entity%ROWTYPE IS
    RESULT entity%ROWTYPE;
  BEGIN
    SELECT *
      INTO RESULT
      FROM (SELECT e.*
              FROM entity e
             START WITH e.ent_id = p_ent_id
            CONNECT BY e.ent_id = PRIOR e.parent_id
             ORDER BY LEVEL DESC)
     WHERE rownum = 1;
    RETURN RESULT;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.12.2008 11:27:01
  -- Purpose : Генерация комментов на ven
  PROCEDURE gen_ent_ven_comments(p_ent_source VARCHAR2) IS
    proc_name VARCHAR2(30) := 'ents.gen_ent_ven_comments';
  BEGIN
    FOR r IN (SELECT *
                FROM all_col_comments
               WHERE table_name IN (SELECT SOURCE
                                      FROM entity e
                                     START WITH e.source = p_ent_source
                                    CONNECT BY PRIOR e.parent_id = e.ent_id))
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'COMMENT ON COLUMN INS.' || v_view || p_ent_source || '.' || r.column_name ||
                          ' IS ''' || r.comments || '''';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      --     EXEC('COMMENT ON COLUMN INS.VEN_'||p_ent_source||'.'|| r.column_name ||' IS '''|| r.comments||'''','Добавляем комментарии на столбцы ven');
    --     dbms_output.put_line ('COMMENT ON COLUMN INS.VEN_'||SOURCE|| r.column_name ||' IS '|| r.comments);
    END LOOP;
    --EXCEPTION
    --  WHEN OTHERS THEN
    --  RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении '||proc_name||SQLERRM);
  END gen_ent_ven_comments;

  -- Генерация представления для сущности
  PROCEDURE gen_ent_ven(p_ent_id IN NUMBER) IS
    v_ent          entity%ROWTYPE;
    v_ent_is_trans NUMBER; -- У сущности имеются атрибуты, требующие многоязычной поддрежки
    v_par          entity%ROWTYPE;
    v_sql          VARCHAR2(32000);
    v_doc_e        PLS_INTEGER := 37; --ent.id_by_brief('DOCUMENT');
    v_doc_templ    PLS_INTEGER;
    v_ins          VARCHAR2(32000);
    v_insv         VARCHAR2(32000);
    v_ins_ml       VARCHAR2(32000);
    v_upd          VARCHAR2(32000);
    v_updv         VARCHAR2(32000);
    v_updt         VARCHAR2(32000);
    v_updtv        VARCHAR2(32000);
    v_updt_ml      VARCHAR2(32000);
    v_updtv_ml     VARCHAR2(32000);
    v_upd_ml       VARCHAR2(32000);
    v_del_ml       VARCHAR2(32000);
  BEGIN
    SELECT e.* INTO v_ent FROM entity e WHERE e.ent_id = p_ent_id;
  
    SELECT COUNT(*)
      INTO v_ent_is_trans
      FROM attr a
     WHERE a.ent_id = p_ent_id
       AND a.is_trans = 1;
  
    IF v_ent_is_trans > 0
    THEN
      v_ent_is_trans := 1;
    END IF;
  
    -- Представление сущности
    v_sql := 'create or replace view ' || v_view || v_ent.source || ' as' || chr(13) || 'select ';
    FOR v_c IN (SELECT decode(l, 1, 't', 'v') || '.' || ac.col_name NAME
                      ,ac.is_trans
                      ,ac.attr_id
                  FROM (SELECT LEVEL l
                              ,e.*
                          FROM entity e
                         START WITH e.ent_id = p_ent_id
                        CONNECT BY e.ent_id = PRIOR e.parent_id) te
                 INNER JOIN ve_attr_col ac
                    ON ac.ent_id = te.ent_id
                   AND ac.attr_type_brief <> 'C'
                 WHERE NOT (te.ent_id <> p_ent_id AND ac.attr_type_brief IN ('OF', 'OI'))
                 ORDER BY decode(ac.attr_type_brief, 'OI', 1, 'OE', 2, 'OF', 3)
                         ,decode(ac.col_name, 'EXT_ID', 1, 2)
                         ,te.l DESC
                         ,ac.col_name)
    LOOP
      IF v_c.is_trans = 1
      THEN
        v_sql := v_sql || 'ent.trans(' || v_c.attr_id || ', t.' || v_ent.id_name || ', ' || v_c.name || ') ' ||
                 substr(v_c.name, 3);
      ELSE
        v_sql := v_sql || v_c.name;
      END IF;
      v_sql := v_sql || ',' || chr(13) || '       ';
    END LOOP;
    v_sql := substr(v_sql, 1, length(v_sql) - 9) || chr(13) || 'from ' || v_ent.source || ' t';
  
    IF v_ent.parent_id IS NOT NULL
    THEN
      SELECT e.* INTO v_par FROM entity e WHERE e.ent_id = v_ent.parent_id;
      v_sql := v_sql || chr(13) || '     inner join ' || v_view || v_par.source || ' v on v.' ||
               v_par.id_name || ' = t.' || v_ent.id_name;
    END IF;
  
    IF v_ent.is_filial = 1
    THEN
      v_sql := v_sql || chr(13) || 'where t.filial_id = ents.get_filial_id' || chr(13) ||
               '      or ents.get_filial_id is null';
    END IF;
    exec(lower(v_sql)
        ,'Создание представления ' || v_view || v_ent.source || ' по сущности №' || p_ent_id);
  
    -- Триггер на представления сущности
    v_sql := 'create or replace trigger ' || v_trigger || v_ent.source ||
             ' instead of insert or update or delete on ' || v_view || v_ent.source || chr(10) ||
             'declare' || chr(10) || '  v_obj_id number;' || chr(10) || '  v_ent_id number;' ||
             chr(10) || '  v_err varchar2(4000);' || chr(10);
  
    IF v_ent.parent_id = v_doc_e
    THEN
      v_sql := v_sql || '  v_doc_templ_id pls_integer;' || chr(10);
    END IF;
  
    IF v_ent.is_audit = 1
    THEN
      v_sql := v_sql || '  v_event_val clob;' || chr(10);
    END IF;
    v_sql := v_sql || 'begin' || chr(10);
  
    -- Добавление и изменение
    v_ins := '  if inserting then' || chr(10) || '    if :new.' || v_ent.id_name || ' is null then' ||
             chr(10) || '      select ' || v_sequence || v_ent.source ||
             '.nextval into v_obj_id from dual;' || chr(10) || '    else' || chr(10) ||
             '      v_obj_id := :new.' || v_ent.id_name || ';' || chr(10) || '    end if;' || chr(10) ||
             '    if :new.ent_id is null then' || chr(10) || '      v_ent_id := ' || v_ent.ent_id || ';' ||
             chr(10) || '    else' || chr(10) || '      v_ent_id := :new.ent_id;' || chr(10) ||
             '    end if;' || chr(10);
    IF v_ent.parent_id = v_doc_e
    THEN
    
      BEGIN
        SELECT dt.doc_templ_id INTO v_doc_templ FROM doc_templ dt WHERE dt.doc_ent_id = v_ent.ent_id;
      
        v_ins := v_ins || '  if :new.doc_templ_id is null then' || chr(10) ||
                 '     v_doc_templ_id := ' || v_doc_templ || ';' || chr(10) ||
                 '  else v_doc_templ_id := :new.doc_templ_id;' || chr(10) || '  end if;' || chr(10);
      EXCEPTION
        WHEN OTHERS THEN
          v_ins := v_ins || '  v_doc_templ_id := :new.doc_templ_id;' || chr(10);
      END;
    
    END IF;
  
    v_upd := '  elsif updating then ' || chr(10) || '    v_obj_id := :old.' || v_ent.id_name || ';' ||
             chr(10);
  
    IF v_ent.is_audit = 1
    THEN
      v_upd := v_upd || '    v_ent_id := :old.ent_id;' || chr(10) || '    if v_ent_id = ' ||
               v_ent.ent_id || ' then' || chr(10) ||
               '      v_event_val := dbms_xmlgen.getXML(''select * from ' || v_view || v_ent.source ||
               ' where ' || v_ent.id_name || ' = '' || v_obj_id );' || chr(10) ||
               '      safety.reg_event_upd(v_ent_id, v_obj_id, ent.obj_name(v_ent_id, v_obj_id), v_event_val);' ||
               chr(10) || '    end if;' || chr(10);
    END IF;
  
    IF v_ent.parent_id IS NOT NULL
    THEN
      v_ins := v_ins || '    insert into ' || v_view || v_par.source || ' (';
      v_upd := v_upd || '    update ' || v_view || v_par.source || ' set (';
      FOR v_c IN (SELECT ac.col_name NAME
                        ,decode(ac.is_null, 'N', ents.col_def_val(ac.source, ac.col_name)) def_val
                    FROM (SELECT LEVEL l
                                ,e.*
                            FROM entity e
                           START WITH e.ent_id = v_ent.parent_id
                          CONNECT BY e.ent_id = PRIOR e.parent_id) te
                   INNER JOIN ve_attr_col ac
                      ON ac.ent_id = te.ent_id
                   WHERE (ac.attr_type_brief NOT IN ('OI', 'OF') OR te.l = 1)
                     AND ac.attr_type_brief <> 'C'
                   ORDER BY 1)
      LOOP
        IF v_c.name = v_par.id_name
        THEN
          v_ins  := v_ins || v_par.id_name || ', ';
          v_insv := v_insv || 'v_obj_id, ';
        ELSIF v_c.name = 'ENT_ID'
        THEN
          v_ins  := v_ins || v_c.name || ', ';
          v_insv := v_insv || 'v_ent_id, ';
        ELSIF v_c.name = 'FILIAL_ID'
        THEN
          v_ins  := v_ins || v_c.name || ', ';
          v_insv := v_insv || 'ents.filial_id, ';
          v_upd  := v_upd || v_c.name || ', ';
          v_updv := v_updv || 'ents.filial_id, ';
        ELSIF v_c.name = 'DOC_TEMPL_ID'
        THEN
          v_ins  := v_ins || v_c.name || ', ';
          v_insv := v_insv || 'v_doc_templ_id, ';
        ELSE
          v_ins := v_ins || v_c.name || ', ';
          IF v_c.def_val IS NOT NULL
          THEN
            v_insv := v_insv || 'nvl(' || ':new.' || v_c.name || ', ' || v_c.def_val || '), ';
          ELSE
            v_insv := v_insv || ':new.' || v_c.name || ', ';
          END IF;
          v_upd  := v_upd || v_c.name || ', ';
          v_updv := v_updv || ':new.' || v_c.name || ', ';
        END IF;
      END LOOP;
      v_ins := cut2(v_ins) || ')' || chr(10) || '      values(' || cut2(v_insv) || ');' || chr(10);
      v_upd := cut2(v_upd) || ')' || chr(10) || '      = (select ' || cut2(v_updv) || ' from dual)' ||
               chr(10) || '    where ' || v_par.id_name || ' = v_obj_id;' || chr(10);
    END IF;
  
    v_ins    := v_ins || '    insert into ' || v_ent.source || '(';
    v_insv   := '';
    v_ins_ml := '';
  
    v_updt     := '    update ' || v_ent.source || ' set (';
    v_updt_ml  := '  ' || v_updt;
    v_updtv    := '';
    v_updtv_ml := '';
    v_upd_ml   := '';
  
    v_del_ml := '';
  
    FOR v_c IN (SELECT ac.attr_id
                      ,ac.source
                      ,ac.col_name NAME
                      ,decode(ac.is_null, 'N', ents.col_def_val(ac.source, ac.col_name)) def_val
                      ,ac.is_trans
                  FROM ve_attr_col ac
                 WHERE ac.ent_id = p_ent_id
                   AND ac.attr_type_brief <> 'C')
    LOOP
      IF v_c.name = v_ent.id_name
      THEN
        v_ins  := v_ins || v_c.name || ', ';
        v_insv := v_insv || 'v_obj_id, ';
      ELSIF v_c.name = 'ENT_ID'
      THEN
        v_ins  := v_ins || v_c.name || ', ';
        v_insv := v_insv || 'v_ent_id, ';
      ELSIF v_c.name = 'FILIAL_ID'
      THEN
        v_ins      := v_ins || v_c.name || ', ';
        v_insv     := v_insv || 'ents.filial_id, ';
        v_updt     := v_updt || v_c.name || ', ';
        v_updtv    := v_updtv || 'ents.filial_id, ';
        v_updt_ml  := v_updt_ml || v_c.name || ', ';
        v_updtv_ml := v_updtv_ml || 'ents.filial_id, ';
      ELSE
        -- ins
        v_ins := v_ins || v_c.name || ', ';
        IF v_c.def_val IS NOT NULL
        THEN
          v_insv := v_insv || 'nvl(' || ':new.' || v_c.name || ', ' || v_c.def_val || '), ';
        ELSE
          v_insv := v_insv || ':new.' || v_c.name || ', ';
        END IF;
        IF v_c.is_trans = 1
        THEN
          v_ins_ml := v_ins_ml || '      ents.trans_ins(' || v_c.attr_id || ', v_obj_id, ' || ':new.' ||
                      v_c.name || ', ''' || v_c.source || '.' || v_c.name || ''');' || chr(10);
        END IF;
      
        -- upd
        v_updt  := v_updt || v_c.name || ', ';
        v_updtv := v_updtv || ':new.' || v_c.name || ', ';
        IF v_c.is_trans = 1
        THEN
          v_upd_ml := v_upd_ml || '      ents.trans_upd(' || v_c.attr_id || ', v_obj_id, ' || ':new.' ||
                      v_c.name || ', ''' || v_c.source || '.' || v_c.name || ''');' || chr(10);
        ELSE
          v_updt_ml  := v_updt_ml || v_c.name || ', ';
          v_updtv_ml := v_updtv_ml || ':new.' || v_c.name || ', ';
        END IF;
      
        -- del
        IF v_c.is_trans = 1
        THEN
          v_del_ml := v_del_ml || '      ents.trans_del(' || v_c.attr_id || ', v_obj_id);' || chr(10);
        END IF;
      END IF;
    END LOOP;
  
    v_ins := cut2(v_ins) || ')' || chr(10) || '      values(' || cut2(v_insv) || ');' || chr(10);
    IF v_ent_is_trans = 1
    THEN
      v_ins := v_ins || '    if ents.lang_id <> ents.sys_lang_id then ' || chr(10) || v_ins_ml ||
               '    end if;' || chr(10);
      v_upd := v_upd || '    if ents.lang_id <> ents.sys_lang_id then ' || chr(10) || cut2(v_updt_ml) || ')' ||
               chr(10) || '        = (select ' || cut2(v_updtv_ml) || ' from dual)' || chr(10) ||
               '      where ' || v_ent.id_name || ' = v_obj_id;' || chr(10) || v_upd_ml || '    else' ||
               chr(10) || '  ' || cut2(v_updt) || ')' || chr(10) || '        = (select ' ||
               cut2(v_updtv) || ' from dual)' || chr(10) || '      where ' || v_ent.id_name ||
               ' = v_obj_id;' || chr(10) || '    end if;' || chr(10);
    ELSE
      v_upd := v_upd || cut2(v_updt) || ')' || chr(10) || '      = (select ' || cut2(v_updtv) ||
               ' from dual)' || chr(10) || '    where ' || v_ent.id_name || ' = v_obj_id;' || chr(10);
    END IF;
    IF v_ent.is_audit = 1
    THEN
      v_ins := v_ins || '    if v_ent_id = ' || v_ent.ent_id || ' then' || chr(10) ||
               '      safety.reg_event_ins(v_ent_id, v_obj_id, ent.obj_name(v_ent_id, v_obj_id), null);' ||
               chr(10) || '    end if;' || chr(10);
    END IF;
    v_sql := v_sql || v_ins || chr(10) || v_upd || chr(10);
  
    -- Удаление
    v_sql := v_sql || '  elsif deleting then' || chr(10) || '    v_obj_id := :old.' || v_ent.id_name || ';' ||
             chr(10);
    IF v_ent.is_audit = 1
    THEN
      v_sql := v_sql || '    v_ent_id := :old.ent_id;' || chr(10) || '    if v_ent_id = ' ||
               v_ent.ent_id || ' then' || chr(10) ||
               '      v_event_val := dbms_xmlgen.getXML(''select * from ' || v_view || v_ent.source ||
               ' where ' || v_ent.id_name || ' = '' || v_obj_id);' || chr(10) ||
               '      safety.reg_event_del(v_ent_id, v_obj_id, ent.obj_name(v_ent_id, v_obj_id), v_event_val);' ||
               chr(10) || '    end if;' || chr(10);
    END IF;
    IF v_ent.parent_id IS NOT NULL
    THEN
      v_sql := v_sql || chr(10) || '    delete from ' || v_view || v_par.source || ' where ' ||
               v_par.id_name || ' = v_obj_id;' || chr(10);
    ELSE
      v_sql := v_sql || '    delete from ' || v_ent.source || ' where ' || v_ent.id_name ||
               ' = v_obj_id;' || chr(10);
    END IF;
    IF v_ent_is_trans = 1
    THEN
      v_sql := v_sql || '    if ents.lang_id <> ents.sys_lang_id then ' || chr(10) || v_del_ml ||
               '    end if;' || chr(10);
    END IF;
    v_sql := v_sql || '  end if;' || chr(10);
  
    -- Обработка ошибок
    v_sql := v_sql || chr(10) || 'exception' || chr(10) || '  when others then' || chr(10) ||
             '    v_err := ents.trans_err(sqlcode, sqlerrm);' || chr(10) ||
             '    if v_err is null then' || chr(10) || '      raise;' || chr(10) || '    else' ||
             chr(10) || '      raise_application_error(-20000, v_err);' || chr(10) || '    end if;' ||
             chr(10) || 'end;';
  
    exec(lower(v_sql)
        ,'Создание триггера на представление ' || v_view || v_ent.source || ' по сущности №' ||
         p_ent_id);
  
    ents.gen_ent_ven_comments(v_ent.source);
  
  END;

  -- получить название ИД поля сущности
  FUNCTION get_ent_pk(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
    RESULT VARCHAR2(30);
  BEGIN
    SELECT nvl(e.id_name, e.source || '_ID') INTO RESULT FROM entity e WHERE e.ent_id = p_ent_id;
    RETURN RESULT;
  END;

  -- Сгенерить синоним для VIEW сущности в схеме dev_owner
  PROCEDURE gen_ent_dev_synonym
  (
    p_ent_id    IN NUMBER DEFAULT NULL
   ,p_ent_brief IN VARCHAR2 DEFAULT NULL
  ) IS
    v_source VARCHAR2(200);
  BEGIN
    IF p_ent_id IS NULL
       AND p_ent_brief IS NULL
    THEN
      raise_application_error(-20100
                             ,'Необходимо задать код или краткое наименование сущности');
    END IF;
    SELECT SOURCE
      INTO v_source
      FROM entity
     WHERE nvl(p_ent_id, ent_id - 1) = ent_id
        OR nvl(p_ent_brief, p_ent_brief || '#') = brief;
    EXECUTE IMMEDIATE 'grant all on ' || v_view || v_source || ' to ' || ents.dev_owner;
    EXECUTE IMMEDIATE 'grant all on ' || v_sequence || v_source || ' to ' || ents.dev_owner;
    EXECUTE IMMEDIATE 'create or replace synonym ' || ents.dev_owner || '.' || v_view || v_source ||
                      ' for ' || v_view || v_source;
    EXECUTE IMMEDIATE 'create or replace synonym ' || ents.dev_owner || '.' || v_sequence || v_source ||
                      ' for ' || v_sequence || v_source;
  END;

  PROCEDURE gen_ent_all
  (
    p_ent_brief VARCHAR2
   ,p_cascade   NUMBER DEFAULT 1
  ) AS
    v_id NUMBER;
  BEGIN
    FOR rc IN (SELECT e.ent_id FROM entity e WHERE upper(e.brief) = upper(p_ent_brief))
    LOOP
      v_id := rc.ent_id;
    END LOOP;
    --v_id := ent.id_by_brief(p_ent_brief);
    IF v_id IS NOT NULL
    THEN
      ents.gen_ent_all(v_id, p_cascade);
    END IF;
  END;

  PROCEDURE gen_ent_all
  (
    p_ent_id  NUMBER DEFAULT NULL
   ,p_cascade NUMBER DEFAULT 1
  ) IS
    v_err VARCHAR2(32000);
  BEGIN
    IF p_ent_id IS NULL
    THEN
      ents.gen_obj_all;
    END IF;
    --gen_uref_check;
    IF p_ent_id IS NULL
    THEN
      FOR v_r IN (SELECT ent_id FROM entity ORDER BY ent_id)
      LOOP
        BEGIN
          ents.gen_ent_src(v_r.ent_id);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
    ELSE
      FOR v_r IN (SELECT ent_id
                    FROM entity
                   START WITH ent_id = p_ent_id
                  CONNECT BY PRIOR ent_id = parent_id
                            -- Байтин А.
                            -- генерировать объекты для дочерних сущностей
                         AND p_cascade = 1
                  
                  )
      LOOP
        BEGIN
          ents.gen_ent_src(v_r.ent_id);
        EXCEPTION
          WHEN OTHERS THEN
            v_err := v_err || chr(10) || SQLERRM;
        END;
      
        IF v_err IS NOT NULL
        THEN
          raise_application_error(-20000
                                 ,'Ошибки генерации сущности:' || chr(10) || v_err);
        END IF;
      END LOOP;
    END IF;
  END;

  PROCEDURE gen_obj_all IS
  BEGIN
    ents.gen_obj_name;
    ents.gen_obj_lock;
    ents.gen_obj_del;
    ents.gen_obj_list;
  END;

  -- генерация проверки ent_id
  PROCEDURE gen_check_ent_id(p_ent_id IN NUMBER) IS
    v_list      VARCHAR2(3000);
    v_src       VARCHAR2(30);
    v_schema    VARCHAR2(30);
    v_parent_id NUMBER(6);
    n           NUMBER;
  BEGIN
    -- Получение главного родителя сущности
    SELECT e.ent_id
          ,e.source
          ,e.schema_name
      INTO v_parent_id
          ,v_src
          ,v_schema
      FROM entity e
     WHERE e.parent_id IS NULL
     START WITH e.ent_id = p_ent_id
    CONNECT BY e.ent_id = PRIOR e.parent_id;
  
    -- Заполнение списка потомков сущности
    v_list := '0';
    FOR v_r IN (SELECT ent_id
                  FROM entity
                 WHERE abstract = 0
                 START WITH ent_id = v_parent_id
                CONNECT BY PRIOR ent_id = parent_id)
    LOOP
      IF v_list = '0'
      THEN
        v_list := v_r.ent_id;
      ELSE
        v_list := v_list || ', ' || v_r.ent_id;
      END IF;
    END LOOP;
  
    SELECT COUNT(*)
      INTO n
      FROM user_constraints c
     WHERE c.constraint_name = v_check || v_src
       AND c.owner = v_schema
       AND c.constraint_type = 'C'
       AND c.table_name = v_src;
    IF n > 0
    THEN
      exec('alter table ' || v_schema || '.' || v_src || ' drop constraint ' || v_check || v_src
          ,'Удаление проверки допустимых значений для поля ENT_ID таблицы ' || v_src);
    END IF;
    exec('alter table ' || v_src || ' add constraint ' || v_check || v_src || ' check (ENT_ID in (' ||
         v_list || '))'
        ,'Создание проверки допустимых значений для поля ENT_ID таблицы ' || v_src);
  END;

  PROCEDURE create_ent
  (
    p_source       IN VARCHAR2
   ,p_name         IN VARCHAR2
   ,p_brief        IN VARCHAR2
   ,p_parent_brief IN VARCHAR2 DEFAULT NULL
  ) IS
    v_ent_id        NUMBER(6);
    v_parent_id     NUMBER(6);
    v_brief         VARCHAR2(30);
    v_source        VARCHAR2(30);
    v_parent_source VARCHAR2(30);
    n               NUMBER;
  BEGIN
    IF USER <> ents.v_sch
    THEN
      raise_application_error(-20000, 'Выбрана неверная схема.');
    END IF;
    IF length(p_name) > 150
       OR length(p_parent_brief) > 150
    THEN
      raise_application_error(-20000
                             ,'Неверная длина наименования сущности.');
    END IF;
    IF length(p_brief) > 50
    THEN
      raise_application_error(-20000
                             ,'Неверная длина сокращения сущности.');
    END IF;
    IF length(p_source) > 20
    THEN
      raise_application_error(-20000
                             ,'Неверная длина наименования таблицы сущности.');
    END IF;
  
    v_source := upper(p_source);
    v_brief  := upper(p_brief);
  
    -- родительская сущность
    IF p_parent_brief IS NULL
    THEN
      v_parent_id := NULL;
    ELSE
      SELECT e.ent_id
            ,e.source
        INTO v_parent_id
            ,v_parent_source
        FROM entity e
       WHERE e.brief = upper(p_parent_brief);
    END IF;
  
    SELECT COUNT(*) INTO n FROM entity e WHERE (upper(e.name) = upper(p_name) OR e.brief = v_brief);
  
    IF n = 0
    THEN
      SELECT sq_entity.nextval INTO v_ent_id FROM dual;
      INSERT INTO entity
        (ent_id, parent_id, NAME, brief, SOURCE, schema_name, id_name)
      VALUES
        (v_ent_id, v_parent_id, p_name, v_brief, v_source, ents.v_sch, v_source || '_ID');
      COMMIT;
    ELSE
      SELECT e.ent_id INTO v_ent_id FROM entity e WHERE e.brief = v_brief;
    END IF;
  
    -- генерация сущности
    ents.gen_ent_src(v_ent_id);
  
    -- пересоздание триггера CHE_DOCUMENT
    IF p_parent_brief IS NOT NULL
    THEN
      create_che_document_trg;
    END IF;
  END;

  PROCEDURE gen_err(p_ent_id IN NUMBER DEFAULT NULL) AS
  BEGIN
    DELETE FROM entity_err ee
     WHERE ee.is_user = 0
       AND (p_ent_id IS NULL OR ee.ent_id = p_ent_id);
    COMMIT;
  
    INSERT INTO entity_err
      SELECT sq_entity_err.nextval
            ,'-1400'
            ,'%("' || e.schema_name || '"."' || a.source || '"."' || a.col_name || '")'
            ,'Незаполнен атрибут "' || a.name || '" сущности "' || e.name || '".'
            ,0
            ,e.ent_id
        FROM entity e
       INNER JOIN attr a
          ON a.ent_id = e.ent_id
       INNER JOIN user_tab_columns utc
          ON utc.table_name = a.source
         AND utc.column_name = a.col_name
         AND utc.nullable = 'N'
       WHERE p_ent_id IS NULL
          OR e.ent_id = p_ent_id;
    COMMIT;
  
    upd_tmp('uc');
    upd_tmp('ucc');
    COMMIT;
  
    INSERT INTO entity_err
      SELECT sq_entity_err.nextval
            ,'-2291'
            ,'%(' || e.schema_name || '.' || uc.constraint_name || ') - %'
            ,'Атрибут "' || a.name || '" сущности "' || e.name ||
             '" ссылается на несуществующий объект сущности "' || r_e.name || ' ".'
            ,0
            ,e.ent_id
        FROM entity e
       INNER JOIN tmp_uc uc
          ON uc.owner = e.schema_name
         AND uc.table_name = e.source
         AND uc.constraint_type = 'R'
       INNER JOIN tmp_ucc ucc
          ON ucc.owner = uc.owner
         AND ucc.constraint_name = uc.constraint_name
         AND ucc.table_name = uc.table_name
       INNER JOIN attr a
          ON a.ent_id = e.ent_id
         AND a.col_name = ucc.column_name
       INNER JOIN tmp_uc r_uc
          ON r_uc.owner = uc.r_owner
         AND r_uc.constraint_name = uc.r_constraint_name
       INNER JOIN entity r_e
          ON r_e.schema_name = r_uc.owner
         AND r_e.source = r_uc.table_name
       WHERE (p_ent_id IS NULL OR e.ent_id = p_ent_id)
         AND (SELECT COUNT(*)
                FROM tmp_ucc ucc_n
               WHERE ucc_n.owner = uc.owner
                 AND ucc_n.constraint_name = uc.constraint_name
                 AND ucc_n.table_name = uc.table_name) = 1;
    COMMIT;
  END;

  PROCEDURE gen_ent_src(p_ent_id IN NUMBER) IS
    v_src        VARCHAR2(30);
    v_parent_src VARCHAR2(30);
    v_parent_id  NUMBER;
    v_abstract   NUMBER(1);
    v_name       VARCHAR2(150);
    v_note       VARCHAR2(4000);
    v_pk         VARCHAR2(30);
    n            NUMBER;
    v_is_guid    NUMBER(1);
    v_cnt        NUMBER(1);
  BEGIN
    SELECT e.name
          ,e.source
          ,pe.source
          ,e.abstract
          ,e.note
          ,e.id_name
          ,e.parent_id
          ,e.is_guid
      INTO v_name
          ,v_src
          ,v_parent_src
          ,v_abstract
          ,v_note
          ,v_pk
          ,v_parent_id
          ,v_is_guid
      FROM entity e
      LEFT OUTER JOIN entity pe
        ON pe.ent_id = e.parent_id
     WHERE e.ent_id = p_ent_id;
  
    -- создаем таблицу сущности
    SELECT COUNT(*) INTO n FROM user_tables ut WHERE ut.table_name = v_src;
    IF n = 0
    THEN
      exec('create table ' || v_src || '(' || ents.get_ent_pk(p_ent_id) || ' number not null)'
          ,'Создание таблицы сущности');
    END IF;
  
    -- создаем поля сущности
    IF v_parent_src IS NULL
    THEN
      IF v_is_guid = 1
      THEN
        exec('alter table ' || v_src || ' add(guid char(32) default sys_guid() not null)'
            ,'Добавление столбца "guid char(32) default sys_guid() not null" в таблицу ' || v_src
            ,-01430);
      END IF;
      IF v_abstract = 1
      THEN
        exec('alter table ' || v_src || ' add(ent_id number(6) not null, filial_id number(6))'
            ,'Добавление столбцов "ent_id number(6) not null, filial_id number(6)" в таблицу ' ||
             v_src
            ,-01430);
      ELSE
        -- Байтин
        -- Проверка существования поля ent_id
        SELECT COUNT(1)
          INTO v_cnt
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM user_tab_columns tc
                 WHERE tc.table_name = v_src
                   AND column_name = 'ENT_ID');
        IF v_cnt = 0
        THEN
          exec('alter table ' || v_src || ' add(ent_id number(6) default ' || p_ent_id ||
               ' not null)'
              ,'Добавление столбца "ent_id number(6) default ' || p_ent_id || ' not null" в таблицу ' ||
               v_src
              ,-01430);
        END IF;
        -- Проверка существования поля filial_id
        SELECT COUNT(1)
          INTO v_cnt
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM user_tab_columns tc
                 WHERE tc.table_name = v_src
                   AND column_name = 'FILIAL_ID');
        IF v_cnt = 0
        THEN
          exec('alter table ' || v_src || ' add(filial_id number(6))'
              ,'Добавление столбца "filial_id number(6)" в таблицу ' || v_src
              ,-01430);
        END IF;
        --
        /*EXEC( 'alter table ' || v_src || ' add(ent_id number(6) default ' || p_ent_id || ' not null, filial_id number(6))',
          'Добавление столбцов "ent_id number(6) default ' || p_ent_id || ' not null, filial_id number(6)" в таблицу ' || v_src,
          -01430
        );*/
      END IF;
      -- Байтин
      -- Проверка существования поля ext_id
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM user_tab_columns tc
               WHERE tc.table_name = v_src
                 AND column_name = 'EXT_ID');
      IF v_cnt = 0
      THEN
        exec('alter table ' || v_src || ' add(ext_id varchar2(50))'
            ,'Добавление столбца "ext_id varchar2(50)" в таблицу ' || v_src
            ,-01430);
      END IF;
    ELSE
      -- Проверка существования поля filial_id
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM user_tab_columns tc
               WHERE tc.table_name = v_src
                 AND column_name = 'FILIAL_ID');
      IF v_cnt = 0
      THEN
        exec('alter table ' || v_src || ' add(filial_id number(6))'
            ,'Добавление столбца "filial_id number(6)" в таблицу ' || v_src
            ,-01430);
      END IF;
      /*EXEC( 'alter table ' || v_src || ' add(filial_id number(6))',
        'Добавление столбца "filial_id number(6)" в таблицу ' || v_src,
        -01430
      );*/
    END IF;
  
    -- Первичный ключ
    SELECT COUNT(*)
      INTO n
      FROM user_constraints  c
          ,user_cons_columns ucc
     WHERE c.constraint_type = 'P'
       AND ucc.owner = ents.v_sch
       AND ucc.constraint_name = c.constraint_name
       AND ucc.position = 1
       AND (ucc.column_name = v_pk OR v_pk IS NULL)
       AND c.table_name = v_src
       AND c.owner = ents.v_sch;
    IF n = 0
    THEN
      IF v_pk IS NULL
      THEN
        v_pk := v_src || '_ID';
      END IF;
      -- Байтин
      -- Проверка существования поля для PK
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM user_tab_columns tc
               WHERE tc.table_name = v_src
                 AND column_name = v_pk);
      IF v_cnt = 0
      THEN
        exec('alter table ' || v_src || ' add(' || v_pk || ' number)'
            ,'Добавление столбца "' || v_pk || ' number" в таблицу ' || v_src
            ,-01430);
      END IF;
      exec('alter table ' || v_src || ' add constraint ' || v_primary || v_src || ' primary key (' || v_pk || ')'
          ,'Создание первичного ключа к таблице ' || v_src);
    ELSIF n = 1
          AND v_pk IS NULL
    THEN
      SELECT ucc.column_name
        INTO v_pk
        FROM user_constraints  c
            ,user_cons_columns ucc
       WHERE c.constraint_type = 'P'
         AND ucc.owner = ents.v_sch
         AND ucc.constraint_name = c.constraint_name
         AND ucc.position = 1
         AND c.table_name = v_src
         AND c.owner = ents.v_sch;
      UPDATE entity e SET e.id_name = v_pk WHERE e.ent_id = p_ent_id;
    END IF;
  
    -- Расстановка комментариев для таблицы и базовых полей
    IF v_note IS NULL
    THEN
      v_note := '';
    ELSE
      v_note := ' | ' || v_note;
    END IF;
    exec('comment on table ' || v_src || ' is ' || '''' || v_name || v_note || ''''
        ,'Добавление комментария к таблице ' || v_src);
    exec('comment on column ' || v_src || '.' || v_pk || ' is ''ИД объекта сущности ' || v_name || ''''
        ,'Добавление комментария к столбцу ' || v_src || '.' || v_pk || ' в таблицу ' || v_src);
    exec('comment on column ' || v_src || '.filial_id is ''ИД филиала'''
        ,'Добавление комментария к столбцу filial_id в таблицу ' || v_src);
    IF v_parent_src IS NULL
    THEN
      exec('comment on column ' || v_src || '.ent_id is ''ИД сущности'''
          ,'Добавление комментария к столбцу ent_id в таблицу ' || v_src);
      exec('comment on column ' || v_src || '.ext_id is ''ИД внешней записи'''
          ,'Добавление комментария к столбцу ext_id в таблицу ' || v_src);
      IF v_is_guid = 1
      THEN
        exec('comment on column ' || v_src || '.guid is ''GUID внешней записи'''
            ,'Добавление комментария к столбцу guid в таблицу ' || v_src);
      END IF;
    END IF;
  
    -- Внешний ключ, для унаследованных сущностей
    IF v_parent_src IS NOT NULL
    THEN
      SELECT COUNT(*)
        INTO n
        FROM user_constraints c
       WHERE c.constraint_type = 'R'
         AND c.owner = ents.v_sch
         AND c.constraint_name = v_foreigni || v_src
         AND c.table_name = v_src;
      IF n = 0
      THEN
        exec('alter table ' || v_src || ' add constraint ' || v_foreigni || v_src || ' foreign key (' || v_pk ||
             ') references ' || v_parent_src || ' (' || ents.get_ent_pk(v_parent_id) ||
             ') on delete cascade DEFERRABLE INITIALLY DEFERRED'
            ,'Создание внешнего ключа для унаследованной сущности к таблице ' || v_src);
      END IF;
    END IF;
  
    -- Последовательность или псевдоним
    IF v_parent_src IS NULL
    THEN
      SELECT COUNT(*) INTO n FROM user_sequences s WHERE s.sequence_name = v_sequence || v_src;
      IF n = 0
      THEN
        exec('create sequence ' || v_sequence || v_src
            ,'Создание последовательности ' || v_sequence || v_src);
      END IF;
    ELSE
      SELECT COUNT(*)
        INTO n
        FROM user_synonyms s
       WHERE s.synonym_name = v_sequence || v_src
         AND s.table_name = v_sequence || v_parent_src;
      IF n = 0
      THEN
        exec('create synonym ' || v_sequence || v_src || ' for ' || v_sequence || v_parent_src
            ,'Создание синонима ' || v_sequence || v_src || ' последовательности ' || v_sequence ||
             v_parent_src);
      END IF;
    END IF;
  
    IF v_parent_src IS NULL
    THEN
      -- Значение по умолчанию для поля ent_id
      IF v_abstract = 1
      THEN
        exec('alter table ' || v_src || ' modify ENT_ID default null'
            ,'Установка значения по умолчанию "ENT_ID default null" таблицы ' || v_src);
      ELSE
        exec('alter table ' || v_src || ' modify ENT_ID default ' || p_ent_id
            ,'Установка значения по умолчанию "ENT_ID default ' || p_ent_id || '" таблицы ' || v_src);
      END IF;
    
      -- Проверка диапазона для поля ent_id
      ents.gen_check_ent_id(p_ent_id);
    END IF;
  
    -- Генерация атрибутов
    ents.gen_attr(p_ent_id);
  
    -- Генерация представление и триггеров
    ents.gen_ent_ven(p_ent_id);
    -- Байтин А.
    -- По идее триггер создается в gen_ent_ven, возможно теперь перестанет падать генерация сущности
    --gen_ent_tr(p_ent_id);
  
    -- Генерируем пакет DML-API для таблицы
    pkg_codegen.generate_and_compile(v_src);
  
    -- Генерация ошибок
    ents.gen_err(p_ent_id);
  END;

  PROCEDURE uref_ins
  (
    p_ent_id NUMBER
   ,p_obj_id NUMBER
  ) IS
  BEGIN
    IF p_ent_id IS NOT NULL
       AND p_obj_id IS NOT NULL
    THEN
      -- insert into uref (ure_id, uro_id) values (p_ent_id, p_obj_id);
      INSERT INTO uref
        (ure_id, uro_id)
        (SELECT p_ent_id
               ,p_obj_id
           FROM dual
          WHERE NOT EXISTS (SELECT 1
                   FROM uref
                  WHERE ure_id = p_ent_id
                    AND uro_id = p_obj_id));
    
    ELSIF p_ent_id IS NULL
          AND p_obj_id IS NOT NULL
    THEN
      raise_application_error(-20000
                             ,'Указан объект, но неуказана сущность для универсальной ссылки.');
    END IF;
  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
  END;

  PROCEDURE uref_del
  (
    p_ent_id NUMBER
   ,p_obj_id NUMBER
  ) IS
  BEGIN
    DELETE FROM uref
     WHERE uref.ure_id = p_ent_id
       AND uref.uro_id = p_obj_id;
  END;

  PROCEDURE uref_clean IS
    v_ure_id NUMBER(6);
    v_uro_id NUMBER;
    CURSOR c_uref IS
      SELECT ure_id
            ,uro_id
        FROM uref;
  BEGIN
    OPEN c_uref;
    LOOP
      FETCH c_uref
        INTO v_ure_id
            ,v_uro_id;
      EXIT WHEN c_uref%NOTFOUND;
      BEGIN
        uref_del(v_ure_id, v_uro_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    CLOSE c_uref;
    COMMIT;
  END;

  PROCEDURE gen_uref_check IS
    v_list   VARCHAR2(3000);
    v_ent_id NUMBER(30);
    n        NUMBER;
    CURSOR c_ent IS
      SELECT ent_id FROM entity WHERE uref = 1;
  BEGIN
    OPEN c_ent;
    FETCH c_ent
      INTO v_ent_id;
    IF NOT c_ent%NOTFOUND
    THEN
      v_list := v_ent_id;
      LOOP
        FETCH c_ent
          INTO v_ent_id;
        EXIT WHEN c_ent%NOTFOUND;
        v_list := v_list || ', ' || v_ent_id;
      END LOOP;
    ELSE
      v_list := 0;
    END IF;
    CLOSE c_ent;
  
    SELECT COUNT(*)
      INTO n
      FROM user_constraints c
     WHERE c.constraint_type = 'C'
       AND c.table_name = 'UREF'
       AND c.constraint_name = 'CHE_UREF';
    IF n = 1
    THEN
      EXECUTE IMMEDIATE 'alter table UREF drop constraint CHE_UREF';
    END IF;
    --dbms_output.put_line('alter table UREF add constraint CHE_UREF check (ure_id in (' ||
    --                    v_list || '))');
    EXECUTE IMMEDIATE 'alter table UREF add constraint CHE_UREF check (ure_id in (' || v_list || '))';
  END;

  PROCEDURE drop_ent_tr(p_ent_id NUMBER) IS
    v_src VARCHAR(30);
  BEGIN
    SELECT e.source
      INTO v_src
      FROM entity e
     INNER JOIN user_triggers t
        ON t.trigger_name = v_trigger || e.source
       AND t.table_name = e.source
     WHERE e.ent_id = p_ent_id;
  
    EXECUTE IMMEDIATE 'drop trigger ' || v_trigger || v_src;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  PROCEDURE gen_ent_tr IS
    v_ent_id NUMBER(6);
    CURSOR c_ent IS
      SELECT ent_id FROM entity;
  BEGIN
    OPEN c_ent;
    LOOP
      FETCH c_ent
        INTO v_ent_id;
      EXIT WHEN c_ent%NOTFOUND;
      BEGIN
        ents.gen_ent_tr(v_ent_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    CLOSE c_ent;
  END;

  FUNCTION uref_col_name(p_name VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN(substr(p_name, 1, length(p_name) - 7));
  END;

  FUNCTION name_from_descr(p_descr VARCHAR2) RETURN VARCHAR2 IS
    v_i NUMBER;
  BEGIN
    v_i := instr(p_descr, '|');
    IF v_i = 0
    THEN
      RETURN(p_descr);
    ELSE
      RETURN(TRIM(substr(p_descr, 1, v_i - 1)));
    END IF;
  END;

  FUNCTION note_from_descr(p_descr VARCHAR2) RETURN VARCHAR2 IS
    v_i NUMBER;
  BEGIN
    v_i := instr(p_descr, '|');
    IF v_i = 0
    THEN
      RETURN(NULL);
    ELSE
      RETURN(TRIM(substr(p_descr, v_i + 1, length(p_descr) - v_i)));
    END IF;
  END;

  FUNCTION attr_db(p_ent_id NUMBER) RETURN tt_ent_db_attr IS
    v_result tt_ent_db_attr := tt_ent_db_attr();
  BEGIN
    FOR vr IN (SELECT ents.name_from_descr(t.name) NAME
                     ,t.brief
                     ,aty.attr_type_id
                     ,t.source
                     ,t.col_name
                     ,ents.note_from_descr(t.name) note
                 FROM (SELECT cc.comments NAME
                             ,CASE
                                WHEN tc.column_name LIKE '%\_URE\_ID' ESCAPE '\' THEN
                                 ents.uref_col_name(tc.column_name)
                                ELSE
                                 tc.column_name
                              END brief
                             ,CASE
                                WHEN tc.column_name LIKE '%\_URE\_ID' ESCAPE '\' THEN
                                 'UR'
                                WHEN tc.column_name = ents.get_ent_pk(p_ent_id) THEN
                                 'OI'
                                WHEN tc.column_name = 'ENT_ID' THEN
                                 'OE'
                                WHEN tc.column_name = 'FILIAL_ID' THEN
                                 'OF'
                                WHEN tc.column_name LIKE '%\_ID' ESCAPE '\' THEN
                                 'R'
                                ELSE
                                 'F'
                              END attr_type
                             ,tc.table_name SOURCE
                             ,tc.column_name col_name
                             ,instr(cc.comments, '|') pos_note
                         FROM entity e
                        INNER JOIN user_tab_columns tc
                           ON tc.table_name = e.source
                          AND tc.column_name NOT LIKE '%\_URO\_ID' ESCAPE '\'
                        INNER JOIN user_col_comments cc
                           ON cc.table_name = e.source
                          AND cc.column_name = tc.column_name
                          AND cc.comments NOT LIKE '*%'
                        WHERE e.ent_id = p_ent_id) t
                INNER JOIN attr_type aty
                   ON aty.brief = t.attr_type)
    LOOP
      v_result.extend();
      v_result(v_result.last) := to_ent_db_attr(vr.name
                                               ,vr.brief
                                               ,vr.attr_type_id
                                               ,vr.source
                                               ,vr.col_name
                                               ,vr.note);
    END LOOP;
    RETURN v_result;
  END;

  -- генерация аттрибутов
  PROCEDURE gen_attr(p_ent_id IN NUMBER) AS
    v_is_guid INTEGER;
  BEGIN
    DELETE FROM attr a
     WHERE a.ent_id = p_ent_id
       AND a.attr_type_id <> (SELECT at.attr_type_id FROM attr_type at WHERE at.brief = 'C')
       AND NOT EXISTS (SELECT 1
              FROM TABLE(CAST(ents.attr_db(p_ent_id) AS tt_ent_db_attr)) t
             WHERE a.source = t.source
               AND a.col_name = t.col_name);
  
    FOR v_r IN (SELECT a.attr_id
                      ,t.*
                  FROM TABLE(CAST(ents.attr_db(p_ent_id) AS tt_ent_db_attr)) t
                 INNER JOIN attr a
                    ON a.ent_id = p_ent_id
                   AND a.source = t.source
                   AND a.col_name = t.col_name)
    LOOP
      UPDATE attr a
         SET a.name  = v_r.name
            ,a.brief = v_r.brief
            ,
             -- a.attr_type_id = decode((select t1.attr_type_id from attr_type t1 where t1.BRIEF in ('RE')),a.attr_type_id,a.attr_type_id,v_r.attr_type_id),
             a.note = v_r.note
       WHERE a.attr_id = v_r.attr_id;
    END LOOP;
  
    FOR v_r IN (SELECT t.*
                  FROM TABLE(CAST(ents.attr_db(p_ent_id) AS tt_ent_db_attr)) t
                 WHERE NOT EXISTS (SELECT *
                          FROM attr a
                         WHERE a.ent_id = p_ent_id
                           AND a.source = t.source
                           AND a.col_name = t.col_name))
    LOOP
      INSERT INTO attr
        (attr_id, ent_id, NAME, brief, attr_type_id, SOURCE, col_name, calc, note)
      VALUES
        (sq_attr.nextval
        ,p_ent_id
        ,v_r.name
        ,v_r.brief
        ,v_r.attr_type_id
        ,v_r.source
        ,v_r.col_name
        ,NULL
        ,v_r.note);
    END LOOP;
  
    SELECT is_guid INTO v_is_guid FROM entity WHERE ent_id = p_ent_id;
  
    --делаем ключевым аттрибутом GUID
    IF v_is_guid = 1
    THEN
      UPDATE attr
         SET is_key = decode(upper(brief), 'GUID', 1, 0)
       WHERE ent_id = p_ent_id
         AND is_key <> decode(upper(brief), 'GUID', 1, 0);
    ELSE
      UPDATE attr
         SET is_key = 0
       WHERE ent_id = p_ent_id
         AND brief = 'GUID'
         AND is_key <> 0;
    END IF;
  
    --делаем невыгружаемыми аттрибуты
    UPDATE attr a
       SET a.is_excl = CASE
                         WHEN a.col_name IN ('EXT_ID')
                              OR a.attr_type_id IN
                              (SELECT at.attr_type_id
                                    FROM attr_type at
                                   WHERE at.brief IN ('OI', 'OE', 'OF'))
                              OR ents.get_col_type(ents.brief_by_id(a.ent_id), a.col_name) IN ('BLOB') THEN
                          1
                         ELSE
                          0
                       END
     WHERE a.ent_id = p_ent_id
       AND a.is_excl = 0;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_msg('Обновление атрибутов сущности №' || p_ent_id || chr(10) || SQLERRM);
  END;

  PROCEDURE fill_obj_name_as_name AS
  BEGIN
    UPDATE entity e
       SET e.obj_name = 'select name into v_result from ' || e.schema_name || '.' || e.source ||
                        ' where ' || nvl(e.id_name, e.source || '_ID') || ' = p_obj_id'
     WHERE e.obj_name IS NULL
       AND e.ent_id IN (SELECT a.ent_id FROM attr a WHERE a.brief = 'NAME');
    UPDATE entity e
       SET e.obj_name = 'select description into v_result from ' || e.schema_name || '.' || e.source ||
                        ' where ' || nvl(e.id_name, e.source || '_ID') || ' = p_obj_id'
     WHERE e.obj_name IS NULL
       AND e.ent_id IN (SELECT a.ent_id FROM attr a WHERE a.brief = 'DESCRIPTION');
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  PROCEDURE gen_user_syn_int(p_user IN VARCHAR2) IS
    v_from VARCHAR2(30);
    v_to   VARCHAR2(30);
  BEGIN
    v_from := upper(ents.v_sch);
    v_to   := upper(p_user);
  
    FOR rc IN (SELECT e.source FROM entity e)
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.' || v_view || rc.source ||
                          ' for ' || v_from || '.' || v_view || rc.source;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      BEGIN
        EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.' || rc.source || ' for ' ||
                          v_from || '.' || rc.source;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      BEGIN
        EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.' || v_sequence || rc.source ||
                          ' for ' || v_from || '.' || v_sequence || rc.source;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  
    EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.ent for ' || v_from || '.ent';
    EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.acc for ' || v_from || '.acc';
    EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.doc for ' || v_from || '.doc';
    EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.utils for ' || v_from || '.utils';
    EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.repcore for ' || v_from || '.repcore';
    FOR v_r IN (SELECT object_name
                  FROM user_objects uo
                 WHERE uo.object_type = 'PACKAGE'
                   AND substr(uo.object_name, 1, 4) = 'PKG_')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.' || v_r.object_name || ' for ' ||
                          v_from || '.' || v_r.object_name;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  
    FOR v_r IN (SELECT object_name
                  FROM user_objects uo
                 WHERE uo.object_type = 'VIEW'
                   AND substr(uo.object_name, 1, 2) = 'V_')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'create or replace synonym ' || v_to || '.' || v_r.object_name || ' for ' ||
                          v_from || '.' || v_r.object_name;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END;

  PROCEDURE gen_user_syn(p_user IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_user IS NULL
    THEN
      FOR v_r IN (SELECT t.sys_user_name FROM sys_user t WHERE t.sys_user_name <> 'INS')
      LOOP
        ents.gen_user_syn_int(v_r.sys_user_name);
      END LOOP;
    ELSE
      ents.gen_user_syn_int(p_user);
    END IF;
  END;

  FUNCTION trunc_name
  (
    p_val IN VARCHAR2
   ,p_len IN NUMBER
  ) RETURN VARCHAR2 AS
  BEGIN
    IF length(p_val) > p_len
    THEN
      RETURN(substr(p_val, 1, p_len - 3) || '...');
    ELSE
      RETURN(p_val);
    END IF;
  END;

  FUNCTION col_def_val
  (
    p_tab IN VARCHAR2
   ,p_col IN VARCHAR2
  ) RETURN VARCHAR2 AS
    v_result VARCHAR2(4000);
    v_val    LONG;
  BEGIN
    SELECT tc.data_default
      INTO v_val
      FROM user_tab_columns tc
     WHERE tc.table_name = p_tab
       AND tc.column_name = p_col;
    v_result := TRIM(substr(v_val, 1, 4000));
    IF upper(v_result) = 'NULL'
    THEN
      v_result := NULL;
    END IF;
    RETURN v_result;
  END;

  PROCEDURE set_null_def
  (
    p_tab IN VARCHAR2
   ,p_col IN VARCHAR2
  ) IS
    v_constr VARCHAR2(30);
    v_str    VARCHAR2(255);
  BEGIN
    SELECT c.constraint_name
      INTO v_constr
      FROM user_cons_columns cc
          ,user_constraints  c
     WHERE c.table_name = upper(p_tab)
       AND cc.column_name = upper(p_col)
       AND cc.constraint_name = c.constraint_name
       AND c.constraint_type = 'C';
    v_str := 'alter table ' || p_tab || ' drop constraint ' || v_constr;
    --    DBMS_OUTPUT.PUT_LINE(v_str);
    EXECUTE IMMEDIATE v_str;
    v_str := 'alter table ' || p_tab || ' add constraint ' || v_constr || ' check (' || p_col ||
             ' IS NOT NULL) deferrable initially deferred';
    --    DBMS_OUTPUT.PUT_LINE(v_str);
    EXECUTE IMMEDIATE v_str;
  END;

  PROCEDURE code_create_obj(p_ent_brief VARCHAR2) AS
  BEGIN
    code_create_obj(id_by_brief(p_ent_brief));
  END;

  PROCEDURE code_create_obj(p_ent_id NUMBER) AS
    v_sql     VARCHAR2(32000);
    v_sql_val VARCHAR2(32000);
    v_src     VARCHAR2(30);
    v_id_name VARCHAR2(30);
    v_len     NUMBER;
  BEGIN
    SELECT lower(e.source)
          ,e.id_name
      INTO v_src
          ,v_id_name
      FROM entity e
     WHERE e.ent_id = p_ent_id;
    --    DBMS_OUTPUT.PUT_LINE('function create_' || v_src ||
    --                         ' (p_ref_id in number) return number as');
    --    DBMS_OUTPUT.PUT_LINE('  v_obj_id number;');
    --    DBMS_OUTPUT.PUT_LINE('begin');
    --    DBMS_OUTPUT.PUT_LINE('  select '||v_sequence || v_src ||
    --                         '.nextval into v_obj_id from dual;');
  
    v_sql     := '  insert into ' || v_view || v_src || ' (';
    v_len     := length(v_sql);
    v_sql_val := NULL;
    FOR v_r IN (SELECT tc.column_name
                  FROM (SELECT LEVEL l
                              ,e.*
                          FROM entity e
                         START WITH e.ent_id = p_ent_id
                        CONNECT BY e.ent_id = PRIOR e.parent_id) te
                 INNER JOIN user_tab_columns tc
                    ON tc.table_name = te.source
                   AND tc.nullable = 'N'
                   AND ents.col_def_val(tc.table_name, tc.column_name) IS NULL
                 INNER JOIN user_col_comments cc
                    ON cc.table_name = tc.table_name
                   AND cc.column_name = tc.column_name
                   AND cc.comments NOT LIKE '*%'
                 WHERE NOT (te.ent_id <> p_ent_id AND cc.column_name = te.id_name)
                   AND cc.column_name NOT IN ('ENT_ID', 'FILIAL_ID')
                 ORDER BY decode(tc.column_name, te.id_name, 1, 2)
                         ,te.l DESC
                         ,tc.column_id)
    LOOP
      IF length(v_sql || v_r.column_name) >= 80
      THEN
        --        DBMS_OUTPUT.PUT_LINE(LOWER(v_sql));
        v_sql := lpad(v_r.column_name, v_len + length(v_r.column_name), ' ') || ', ';
      ELSE
        v_sql := v_sql || v_r.column_name || ', ';
      END IF;
      IF v_sql_val IS NULL
      THEN
        v_sql_val := 'v_obj_id, ';
      ELSE
        v_sql_val := v_sql_val || 'v_' || v_r.column_name || ', ';
      END IF;
    END LOOP;
    --    DBMS_OUTPUT.PUT_LINE(LOWER(cut2(v_sql)) || ')');
    --    DBMS_OUTPUT.PUT_LINE('  values (' ||
    --                         LOWER(cut2(v_sql_val)) || ');');
    --    DBMS_OUTPUT.PUT_LINE('end;');
  END;

  FUNCTION trans_err
  (
    p_num    IN VARCHAR2
   ,p_err    IN VARCHAR2
   ,p_ent_id IN NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 AS
    v_result VARCHAR2(4000);
  BEGIN
    IF p_ent_id IS NULL
    THEN
      SELECT ee.name
        INTO v_result
        FROM entity_err ee
       WHERE ee.num = p_num
         AND substr(p_err, 12, length(p_err) - 11) LIKE ee.mask;
      RETURN v_result || chr(10) || p_err;
    ELSE
      SELECT ee.name
        INTO v_result
        FROM entity_err ee
       WHERE ee.ent_id = p_ent_id
         AND ee.num = p_num
         AND substr(p_err, 12, length(p_err) - 11) LIKE ee.mask;
      RETURN v_result || chr(10) || p_err;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE prepare_ve_error AS
  BEGIN
    upd_tmp('uo');
    upd_tmp('ut');
    upd_tmp('utc');
    upd_tmp('uc');
    upd_tmp('ucc');
    upd_tmp('uic');
    COMMIT;
  END;

  FUNCTION check_name
  (
    p_name   IN VARCHAR2
   ,p_prefix IN VARCHAR2
   ,p_table  IN VARCHAR2
  ) RETURN NUMBER AS
  BEGIN
    IF p_name LIKE p_prefix || substr(p_table, 1, 30 - length(p_prefix)) || '%'
       OR p_name LIKE p_prefix || substr(p_table, 1, 30 - length(p_prefix) - 3) || '%_'
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  FUNCTION get_filial_id RETURN NUMBER AS
  BEGIN
    RETURN ents.filial_id;
  END;

  PROCEDURE trans_ins
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_val     IN VARCHAR2
   ,p_brief   IN VARCHAR
  ) AS
  BEGIN
    INSERT INTO lang_res
      (lang_res_id, attr_id, obj_id, NAME, brief, lang_id)
    VALUES
      (sq_lang_res.nextval, p_attr_id, p_obj_id, p_val, upper(p_brief), ents.lang_id);
  END;

  PROCEDURE trans_upd
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_val     IN VARCHAR2
   ,p_brief   IN VARCHAR
  ) AS
  BEGIN
    UPDATE lang_res lr
       SET NAME = p_val
     WHERE lr.attr_id = p_attr_id
       AND lr.lang_id = ents.lang_id
       AND lr.obj_id = p_obj_id;
    IF SQL%ROWCOUNT = 0
    THEN
      ents.trans_ins(p_attr_id, p_obj_id, p_val, p_brief);
    END IF;
  END;

  PROCEDURE trans_del
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
  ) AS
  BEGIN
    DELETE FROM lang_res lr
     WHERE lr.attr_id = p_attr_id
       AND lr.lang_id = ents.lang_id
       AND lr.obj_id = p_obj_id;
  END;

  PROCEDURE upd_tmp(p_obj IN VARCHAR2) AS
  BEGIN
    CASE upper(p_obj)
      WHEN 'UO' THEN
        DELETE FROM tmp_uo;
        INSERT INTO tmp_uo
          SELECT * FROM user_objects;
      
      WHEN 'UT' THEN
        DELETE FROM tmp_ut;
        INSERT INTO tmp_ut
          SELECT * FROM user_tables;
      
      WHEN 'UTC' THEN
        DELETE FROM tmp_utc;
        INSERT INTO tmp_utc
          SELECT table_name
                ,column_name
                ,data_type
                ,data_type_mod
                ,data_type_owner
                ,data_length
                ,data_precision
                ,data_scale
                ,nullable
                ,column_id
                ,default_length
                ,num_distinct
                ,low_value
                ,high_value
                ,density
                ,num_nulls
                ,num_buckets
                ,last_analyzed
                ,sample_size
                ,character_set_name
                ,char_col_decl_length
                ,global_stats
                ,user_stats
                ,avg_col_len
                ,char_length
                ,char_used
                ,v80_fmt_image
                ,data_upgraded
            FROM user_tab_columns;
      
      WHEN 'UC' THEN
        DELETE FROM tmp_uc;
        INSERT INTO tmp_uc
          SELECT owner
                ,constraint_name
                ,constraint_type
                ,table_name
                ,r_owner
                ,r_constraint_name
                ,delete_rule
                ,status
                ,deferrable
                ,deferred
                ,validated
                ,generated
                ,bad
                ,rely
                ,last_change
                ,index_owner
                ,index_name
                ,invalid
                ,view_related
            FROM user_constraints t;
      
      WHEN 'UCC' THEN
        DELETE FROM tmp_ucc;
        INSERT INTO tmp_ucc
          SELECT * FROM user_cons_columns;
      
      WHEN 'UIC' THEN
        DELETE FROM tmp_uic;
        INSERT INTO tmp_uic
          SELECT * FROM user_ind_columns;
      
      ELSE
        raise_application_error(-20000
                               ,'Неверное значение параметра функции ents.upd_tmp.');
    END CASE;
  END;

  PROCEDURE attr_name_to_descr AS
    v_s VARCHAR2(4000);
  BEGIN
    FOR v_r IN (SELECT a.*
                  FROM attr a
                 WHERE a.attr_type_id IN (4, 5)
                   AND a.col_name NOT IN ('FILIAL_ID', 'ENT_ID', 'EXT_ID')
                 ORDER BY a.name)
    LOOP
      v_s := 'comment on column ' || v_r.source || '.' || v_r.col_name || ' is ' || '''' || v_r.name;
      --      if v_r.note is null then
    --        DBMS_OUTPUT.PUT_LINE(v_s || ''';');
    --      else
    --        DBMS_OUTPUT.PUT_LINE(v_s || ' | ' || v_r.note || ''';');
    --      end if;
    END LOOP;
  END;

  FUNCTION get_safety_max_counter RETURN NUMBER IS
  BEGIN
    RETURN 10;
  END;

  FUNCTION get_safety_max_tries RETURN NUMBER IS
  BEGIN
    RETURN 3;
  END;

  FUNCTION get_safety_pictures_count RETURN NUMBER IS
  BEGIN
    RETURN 1000;
  END;

  FUNCTION get_safety_flag RETURN NUMBER IS
    v_flag NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(flag_robot_protect, 0) INTO v_flag FROM sys_user WHERE sys_user_name = USER;
    EXCEPTION
      WHEN no_data_found THEN
        v_flag := 0;
    END;
    RETURN v_flag;
  END;

  PROCEDURE inc_safety_counter IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF ents.get_safety_flag = 0
    THEN
      RETURN;
    END IF;
  
    UPDATE human_action_counter SET counter = counter + 1 WHERE sys_user_name = USER;
  
    IF (SQL%ROWCOUNT = 0)
    THEN
      INSERT INTO ven_human_action_counter (sys_user_name, counter) VALUES (USER, 0);
    END IF;
  
    COMMIT;
  END;

  PROCEDURE reset_safety_counter IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF ents.get_safety_flag = 0
    THEN
      RETURN;
    END IF;
  
    UPDATE human_action_counter SET counter = 0 WHERE sys_user_name = USER;
  
    IF (SQL%ROWCOUNT = 0)
    THEN
      INSERT INTO ven_human_action_counter (sys_user_name, counter) VALUES (USER, 0);
    END IF;
  
    COMMIT;
  END;

  PROCEDURE repare_objdb_name AS
    v_sql VARCHAR2(4000);
  BEGIN
    FOR v_r IN (SELECT c.*
                  FROM user_constraints c
                 WHERE c.generated = 'USER NAME'
                   AND c.constraint_type IN ('R', 'U', 'C')
                   AND NOT ((c.constraint_type = 'R' AND c.constraint_name = v_foreigni || c.table_name) OR
                        (c.constraint_type = 'R' AND
                        ents.check_name(c.constraint_name, v_foreign, c.table_name) = 1) OR
                        (c.constraint_type = 'U' AND
                        ents.check_name(c.constraint_name, v_unique, c.table_name) = 1))
                   AND NOT ((c.constraint_type = 'C' AND c.constraint_name = v_check || c.table_name) OR
                        ents.check_name(c.constraint_name, 'CH_', c.table_name) = 1))
    LOOP
    
      SELECT MAX(substr(c.constraint_name, -2)) + 1
        INTO v_sql
        FROM user_constraints c
       WHERE c.generated = v_r.generated
         AND c.table_name = v_r.table_name
         AND c.constraint_type = v_r.constraint_type
         AND c.constraint_name <> v_foreigni || c.table_name
         AND substr(c.constraint_name, -1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
         AND substr(c.constraint_name, -2, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
    
      IF v_sql IS NULL
      THEN
        v_sql := v_r.table_name || '_01';
      ELSIF length(v_sql) = 1
      THEN
        v_sql := v_r.table_name || '_0' || v_sql;
      ELSE
        v_sql := v_r.table_name || '_' || v_sql;
      END IF;
    
      IF v_r.constraint_type = 'R'
      THEN
        v_sql := v_foreign || v_sql;
      ELSIF v_r.constraint_type = 'U'
      THEN
        v_sql := v_unique || v_sql;
      ELSIF v_r.constraint_type = 'C'
      THEN
        v_sql := 'CH_' || v_sql;
      ELSE
        raise_application_error(-20000, 'Ошибка типа');
      END IF;
    
      v_sql := 'alter table ' || ents.v_sch || '.' || v_r.table_name || ' rename constraint ' ||
               v_r.constraint_name || ' to ' || v_sql;
      --     dbms_output.put_line(v_sql);
      EXECUTE IMMEDIATE v_sql;
    END LOOP;
  END;

  FUNCTION get_col_type
  (
    p_table_name  VARCHAR2
   ,p_column_name VARCHAR2
  ) RETURN VARCHAR2 IS
    str VARCHAR2(100);
  BEGIN
    SELECT data_type
      INTO str
      FROM user_tab_cols
     WHERE 1 = 1
       AND table_name = p_table_name
       AND column_name = p_column_name;
  
    RETURN str;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_col_type;

  /*
     Байтин А.
     Удаление сущности
     Drop: 
          * Таблица
          * Триггер
          * Представление
          * Последовательность
          * Псевдоним
     Delete: entity (из attr удалится каскадно)
  
     par_entity_brief - Сокращенное название сущности
  */
  PROCEDURE del_ent
  (
    par_entity_brief VARCHAR2
   ,par_drop_table   BOOLEAN DEFAULT TRUE
  ) IS
    v_src    VARCHAR2(30);
    v_ent_id NUMBER;
    v_cnt    NUMBER(1);
  BEGIN
    -- Наименование таблицы
    SELECT en.source
          ,en.ent_id
      INTO v_src
          ,v_ent_id
      FROM entity en
     WHERE en.brief = par_entity_brief;
    -- Удаление таблицы
    IF par_drop_table
    THEN
      -- Проверка существования
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL FROM user_tables ut WHERE ut.table_name = v_src);
      IF v_cnt = 1
      THEN
        exec('drop table ' || v_src, 'Удаление таблицы ' || v_src);
      END IF;
    END IF;
    -- Удаление триггера
    -- Проверка существования
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM user_triggers ut WHERE ut.trigger_name = v_trigger || v_src);
    IF v_cnt = 1
    THEN
      exec('drop trigger ' || v_trigger || v_src
          ,'Удаление триггера ' || v_trigger || v_src);
    END IF;
    -- Удаление представления
    -- Проверка существования
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM user_views ut WHERE ut.view_name = v_view || v_src);
    IF v_cnt = 1
    THEN
      exec('drop view ' || v_view || v_src
          ,'Удаление представления ' || v_view || v_src);
    END IF;
  
    -- Удаление последовательности
    -- Проверка существования
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM user_sequences ut WHERE ut.sequence_name = v_sequence || v_src);
    IF v_cnt = 1
    THEN
      exec('drop sequence ' || v_sequence || v_src
          ,'Удаление последовательности ' || v_sequence || v_src);
    END IF;
  
    -- Удаление синонимов
    FOR r_syn IN (SELECT sy.owner || '.' || sy.object_name AS syn_name
                    FROM all_objects sy
                   WHERE sy.object_type = 'SYNONYM'
                     AND sy.object_name IN (v_src, v_sequence || v_src, v_view || v_src)
                  /*select sy.owner||'.'||sy.synonym_name as syn_name
                   from all_synonyms sy
                  where sy.table_name in (v_src
                                         ,v_sequence||v_src
                                         ,v_view||v_src
                                         )*/
                  )
    LOOP
      exec('drop synonym ' || r_syn.syn_name, 'Удаление синонима ' || r_syn.syn_name);
    END LOOP;
  
    -- Удаление сущности из справочника
    DELETE FROM entity en WHERE en.ent_id = v_ent_id;
  
    COMMIT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'Не найдена запись сущности с указанным сокращенным названием!');
  END del_ent;

END;
/
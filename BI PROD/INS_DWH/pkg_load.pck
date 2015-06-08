CREATE OR REPLACE PACKAGE ins_dwh.pkg_load IS
  /* $Id: pck_load.pck,v 1.10 2007/10/18 13:04:33 tspirin Exp $ */

  --DECLARE
  --  jobno number;
  --BEGIN
  --  dbms_job.change(job => 101,
  --    what => 'pck_load.l_all;',
  --    next_date =>  trunc(SYSDATE, 'DD')+23/24,
  --    interval => 'trunc(SYSDATE, 'DD')+23/24'
  --  );
  --END;

  --
  -- Пакет предназначен для загрузки данных в хранилище IRAO_STAR
  -- Пока все процедуры собраны в одном пакете, позже его можно
  -- будет раскидать...
  --

  ------------------------------------------------------------------
  -- журналирование
  PROCEDURE exec_sql_ign_err(par_sql VARCHAR2);

  -- dbms_output не принимает больше чем 255 символов
  PROCEDURE pra_dbms_output(p_txt IN VARCHAR2);

  PROCEDURE pra_log
  (
    p_txt  IN VARCHAR2
   ,p_type IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pra_log_time
  (
    p_txt  IN VARCHAR2
   ,p_type IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE complete_refresh_mview(par_mview VARCHAR2);

  PROCEDURE ldm_all;

  PROCEDURE lfc_all;

  --------------------------------------------------------------------
  PROCEDURE l_all;

  --
  -- для запуска загрузки из кастома
  --
  FUNCTION l_all_custom
  (
    par_contract_id NUMBER DEFAULT NULL
   ,par_code        VARCHAR2 DEFAULT NULL
   ,par_attribute1  VARCHAR2 DEFAULT NULL
   ,par_attribute2  VARCHAR2 DEFAULT NULL
   ,par_attribute3  VARCHAR2 DEFAULT NULL
   ,par_attribute4  VARCHAR2 DEFAULT NULL
   ,par_attribute5  VARCHAR2 DEFAULT NULL
   ,par_attribute6  VARCHAR2 DEFAULT NULL
   ,par_attribute7  VARCHAR2 DEFAULT NULL
   ,par_attribute8  VARCHAR2 DEFAULT NULL
   ,par_attribute9  VARCHAR2 DEFAULT NULL
   ,par_attribute10 VARCHAR2 DEFAULT NULL
   ,par_attribute11 VARCHAR2 DEFAULT NULL
   ,par_attribute12 VARCHAR2 DEFAULT NULL
   ,par_attribute13 VARCHAR2 DEFAULT NULL
   ,par_attribute14 VARCHAR2 DEFAULT NULL
   ,par_attribute15 VARCHAR2 DEFAULT NULL
   ,par_attribute16 VARCHAR2 DEFAULT NULL
   ,par_attribute17 VARCHAR2 DEFAULT NULL
   ,par_attribute18 VARCHAR2 DEFAULT NULL
   ,par_attribute19 VARCHAR2 DEFAULT NULL
   ,par_attribute20 VARCHAR2 DEFAULT NULL
   ,par_attribute21 VARCHAR2 DEFAULT NULL
   ,par_attribute22 VARCHAR2 DEFAULT NULL
   ,par_attribute23 VARCHAR2 DEFAULT NULL
   ,par_attribute24 VARCHAR2 DEFAULT NULL
   ,par_attribute25 VARCHAR2 DEFAULT NULL
   ,par_attribute26 VARCHAR2 DEFAULT NULL
   ,par_attribute27 VARCHAR2 DEFAULT NULL
   ,par_attribute28 VARCHAR2 DEFAULT NULL
   ,par_attribute29 VARCHAR2 DEFAULT NULL
   ,par_attribute30 VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  --
  -- Универсальная процедура проверки данных
  -- на то, что все коды размерностей в факте преставлены в самих размерностях
  --
  /*
  FUNCTION check_fact_uni(
    par_fact_name VARCHAR2,
    par_dim_names acpdba.type_tab_char2000,
    par_dim_cols  acpdba.type_tab_char2000,
    par_fact_cols acpdba.type_tab_char2000
  ) RETURN BOOLEAN ;
  */
  --------------------------------------------------------------------
  --PROCEDURE check_load_all;

  --------------------------------------------------------------------

  --
  -- Универсальная процедура проверки данных на уникальность по логическому PK
  --  (проблема в том, что по многим таблицам физического нет, т.к. они - вьюхи)
  --
  -- Параметры:
  --  par_tab_name  -- название таблицы
  --  par_col_names -- список колонок-ПК
  --
  /*
  FUNCTION check_factPK_uni(
    par_tab_name  VARCHAR2,
    par_col_names acpdba.type_tab_char2000
  ) RETURN BOOLEAN ;
  */
  --
  -- проверить ПК по всем размерностям и фактам
  --
  --PROCEDURE check_loadPK_all;
  PROCEDURE exec_proc(par_proc VARCHAR2);
  PROCEDURE l_dm_p_pol_header;
  PROCEDURE l_t_fc_epg;
  /*
    Байтин А.
    Заполнение факта ЭПГ для ХКФБ
  */
  PROCEDURE l_t_fc_epg_hkb;
  PROCEDURE upd_t_fc_epg;
  PROCEDURE upd_dm_p_pol_header;
  PROCEDURE l_t_fc_commiss;
  /*PROCEDURE l_t_rl_ops;*/

  -- проверка: является ли строка датой
  FUNCTION is_date
  (
    p_s      IN VARCHAR2
   ,p_format IN VARCHAR2
  ) RETURN NUMBER;

  /*
    Пиядин А.
    Процедура обновления фактов проводок
  */
  PROCEDURE l_fc_trans;

END;
/
CREATE OR REPLACE PACKAGE BODY ins_dwh.pkg_load IS

  -- последня строка, добавленная в журнал. Иногда она нужна
  pvar_last_log_line NUMBER;

  ------------------------------------------------------------------
  -- журналирование и вспомогательные процедуры

  PROCEDURE exec_sql_ign_err(par_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE par_sql;
  EXCEPTION
    WHEN OTHERS THEN
      pra_log(par_sql);
      pra_log(SQLERRM(SQLCODE));
  END exec_sql_ign_err;

  -- dbms_output не принимает больше чем 255 символов
  PROCEDURE pra_dbms_output(p_txt IN VARCHAR2) IS
    i PLS_INTEGER := 1;
  BEGIN
    LOOP
      dbms_output.put_line(substr(convert(p_txt, 'CL8MSWIN1251'), i, 255));
      i := i + 255;
      EXIT WHEN i > length(p_txt);
    END LOOP;
  END pra_dbms_output;

  PROCEDURE pra_log
  (
    p_txt  IN VARCHAR2
   ,p_type IN VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    pra_dbms_output(convert(p_txt, 'CL8MSWIN1251'));
    INSERT INTO fc_dm_log
      (message_id, message_time, message_type, message)
    VALUES
      (sq_fc_dm_log.nextval, SYSDATE, p_type, p_txt)
    RETURNING message_id INTO pvar_last_log_line;
  
    COMMIT;
  END pra_log;

  PROCEDURE pra_log_time
  (
    p_txt  IN VARCHAR2
   ,p_type IN VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    pra_dbms_output(to_char(SYSDATE, 'dd.mm.yyyy hh24:mi:ss') || ': ' ||
                    convert(p_txt, 'CL8MSWIN1251'));
  
    INSERT INTO fc_dm_log
      (message_id, message_time, message_type, message)
    VALUES
      (sq_fc_dm_log.nextval, SYSDATE, p_type, p_txt)
    RETURNING message_id INTO pvar_last_log_line;
  
    COMMIT;
  END pra_log_time;

  -----------------------------------------------------------------------
  PROCEDURE complete_refresh_mview(par_mview VARCHAR2) IS
    var_mview CONSTANT VARCHAR2(2000) := upper(par_mview);
    --  var_sql   VARCHAR2(2000);
  BEGIN
    -- бесполезно, complete refresh их включает взад :о(
    -- надо бы дропать, что ли. Но страшно - вдруг ошибка, они и не построятся
    -- тогда надо здесь их и строить
    -- !!! продумать, если не будет большой лени - то и сделать.
  
    --  -- выключить индексы
    --  FOR r IN (
    --    SELECT d.index_name
    --      FROM dba_indexes d
    --     WHERE d.owner = 'HEATSTAR' AND
    --           d.table_name = var_mview
    --  ) LOOP
    --    pra_log_time('index '||r.index_name||' => UNUSABLE');
    --    var_sql := 'ALTER INDEX '||r.index_name||' UNUSABLE';
    --    EXECUTE IMMEDIATE var_sql;
    --  END LOOP;
  
    -- сказать complete рефреш
    pra_log_time('mview ' || var_mview || ' => REFRESH');
    dbms_mview.refresh(list => var_mview, method => 'C', atomic_refresh => FALSE);
  
    --  -- включить индексы
    --  FOR r IN (
    --    SELECT d.index_name
    --      FROM dba_indexes d
    --     WHERE d.owner = 'HEATSTAR' AND
    --           d.table_name = var_mview
    --  ) LOOP
    --    pra_log_time('index '||r.index_name||' => REBUILD');
    --    var_sql := 'ALTER INDEX '||r.index_name||' REBUILD';
    --    EXECUTE IMMEDIATE var_sql;
    --  END LOOP;
  
    -- прогнать anal
    dbms_stats.gather_table_stats('ins_dwh', var_mview, degree => 1, cascade => TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.complete_refresh_mview(' || par_mview || ') error:', 'E');
      pra_log_time(SQLERRM(SQLCODE));
  END complete_refresh_mview;
  -----------------------------------------------------------------------
  -- загрузка размерностей
  PROCEDURE ldm_all IS
  BEGIN
    --Попробуем обновить в параллель
    --EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL QUERY PARALLEL 4';
  
    IF (pkg_dev_utils.compile_obj = 0)
    THEN
      pra_log_time('pck_load.error_compile');
    ELSE
      pra_log_time('pck_load.ok_compile');
    END IF;
  
    pra_log_time('pck_load.ldm_all started');
  
    FOR rec IN (SELECT dm.meta_data_id
                      ,dm.name_db_object
                      ,dm.type_db_object
                      ,dm.renew_metod
                      ,dm.renew_script
                  FROM meta_data dm
                 WHERE dm.is_renew = 1
                 ORDER BY dm.renew_order)
    LOOP
      IF rec.renew_metod = 'refresh_m_view'
      THEN
        complete_refresh_mview(rec.name_db_object);
      ELSIF rec.renew_metod = 'proc'
      THEN
        BEGIN
          -- todo 1. Отключить, включить индексы.
          --         очищать таблицу внутри процедуры очистки.
          --execute immediate 'truncate table ' || rec.name_db_object;
          exec_proc(rec.renew_script);
        END;
      END IF;
    END LOOP;
  
    --Гаргонов Д.А.
    --Заявка 284706
    UPDATE ins_dwh.meta_data dm
       SET dm.is_renew = 0
     WHERE TRIM(dm.type_db_object) = 'mview'
       AND dm.name_db_object IN ('fc_ag_commis_ksp_total', 'fc_ag_comiss_total')
       AND dm.is_renew = 1;
    COMMIT;
  
    pra_log_time('pck_load.ldm_all stoped');
  
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.ldm_all error:');
      pra_log_time(SQLERRM(SQLCODE));
  END ldm_all;

  --------------------------------------------------------------------
  PROCEDURE lprefc_all IS
  BEGIN
    pra_log_time('pck_load.lprefc_all started');
  
    complete_refresh_mview('pre_fc_fact_oper_expimp');
    complete_refresh_mview('pre_fc_fact_expimp');
    complete_refresh_mview('pre_fc_fact_ore');
    complete_refresh_mview('pre_fc_plan_expimp');
    complete_refresh_mview('pre_fc_plan_ore');
    complete_refresh_mview('pre_fc_fact_oresdd');
    --  complete_refresh_mview('pre_fc_finobligation');
    --  complete_refresh_mview('pre_fc_finpayments');
    --  complete_refresh_mview('pre_fc_invoices');
    complete_refresh_mview('pre_fc_mod_seans');
  
    pra_log_time('pck_load.lprefc_all stoped');
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.lprefc_all error:');
      pra_log_time(SQLERRM(SQLCODE));
  END lprefc_all;

  --------------------------------------------------------------------
  PROCEDURE lfc_all IS
  BEGIN
    lprefc_all;
  
    pra_log_time('pck_load.lfc_all started');
  
    --  complete_refresh_mview('t_fc_hour_deliveries_plan');
    --  complete_refresh_mview('t_fc_hour_deliveries_fact');
  
    --  complete_refresh_mview('fc_deliveries'); -- уже вью
    complete_refresh_mview('fc_hour_deliveries');
    complete_refresh_mview('fc_deals_ore');
    complete_refresh_mview('fc_deals_ore_matrix');
    --  complete_refresh_mview('fc_rgb_hour'); -- уже вью
    --  complete_refresh_mview('fc_fin_results'); -- уже вью
  
    pra_log_time('pck_load.lfc_all stoped');
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.lfc_all error:');
      pra_log_time(SQLERRM(SQLCODE));
  END lfc_all;

  PROCEDURE l_all IS
    var_lockhandle VARCHAR2(128);
    var_lockresult NUMBER;
  BEGIN
    pra_log_time('-');
  
    ---------------------------------------------------------------------------------------
    -- нам надо обеспечить целостность загрузки
    -- для того, чтобы одновременное нажатие на кнопку "обновить" не приводило к катастрофе
    -- для этого заблокируем... ждать будем не более 15 минут
    /*
    DBMS_LOCK.allocate_unique('TAS_DataLoad', var_lockhandle);
    var_lockresult := DBMS_LOCK.request(var_lockhandle, DBMS_LOCK.x_mode, 15*60, FALSE);
    IF var_lockresult <> 0 THEN
      -- Ругнемся, если какие-то ошибки
      pra_log_time('pck_load.l_all error: Ошибка при получении общей блокировки на загрузку данных. Код: '||var_lockresult, 'E');
      RETURN;
    END IF;
    ---------------------------------------------------------------------------------------
    */
    -- ну теперь обработка...
    ldm_all;
    lfc_all;
  
    --check_load_all;
    --check_loadPK_all;
  
    pra_log_time('-');
  
    ---------------------------------------------------------------------------------------
    -- освободим
    /*
    var_lockresult := DBMS_LOCK.release(var_lockhandle);
    IF var_lockresult <> 0 THEN
      -- Ругнемся, если какие то-ошибки
      pra_log_time('pck_load.l_all error: Ошибка при освобождении общей блокировки на загрузку данных. Код: '||var_lockresult, 'E');
    END IF;
    */
    ---------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.l_all error:', 'E');
      pra_log_time(SQLERRM(SQLCODE), 'E');
      /*
      IF var_lockhandle IS NOT NULL THEN
        var_lockresult := DBMS_LOCK.release(var_lockhandle);
      END IF;
      */
  END l_all;

  --
  -- для запуска загрузки из кастома
  --
  FUNCTION l_all_custom
  (
    par_contract_id NUMBER DEFAULT NULL
   ,par_code        VARCHAR2 DEFAULT NULL
   ,par_attribute1  VARCHAR2 DEFAULT NULL
   ,par_attribute2  VARCHAR2 DEFAULT NULL
   ,par_attribute3  VARCHAR2 DEFAULT NULL
   ,par_attribute4  VARCHAR2 DEFAULT NULL
   ,par_attribute5  VARCHAR2 DEFAULT NULL
   ,par_attribute6  VARCHAR2 DEFAULT NULL
   ,par_attribute7  VARCHAR2 DEFAULT NULL
   ,par_attribute8  VARCHAR2 DEFAULT NULL
   ,par_attribute9  VARCHAR2 DEFAULT NULL
   ,par_attribute10 VARCHAR2 DEFAULT NULL
   ,par_attribute11 VARCHAR2 DEFAULT NULL
   ,par_attribute12 VARCHAR2 DEFAULT NULL
   ,par_attribute13 VARCHAR2 DEFAULT NULL
   ,par_attribute14 VARCHAR2 DEFAULT NULL
   ,par_attribute15 VARCHAR2 DEFAULT NULL
   ,par_attribute16 VARCHAR2 DEFAULT NULL
   ,par_attribute17 VARCHAR2 DEFAULT NULL
   ,par_attribute18 VARCHAR2 DEFAULT NULL
   ,par_attribute19 VARCHAR2 DEFAULT NULL
   ,par_attribute20 VARCHAR2 DEFAULT NULL
   ,par_attribute21 VARCHAR2 DEFAULT NULL
   ,par_attribute22 VARCHAR2 DEFAULT NULL
   ,par_attribute23 VARCHAR2 DEFAULT NULL
   ,par_attribute24 VARCHAR2 DEFAULT NULL
   ,par_attribute25 VARCHAR2 DEFAULT NULL
   ,par_attribute26 VARCHAR2 DEFAULT NULL
   ,par_attribute27 VARCHAR2 DEFAULT NULL
   ,par_attribute28 VARCHAR2 DEFAULT NULL
   ,par_attribute29 VARCHAR2 DEFAULT NULL
   ,par_attribute30 VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
    var_seq     NUMBER;
    var_err_ret VARCHAR2(1999);
  BEGIN
    -- для анализа ошибок запомним seq строк журнала
    SELECT sq_fc_dm_log.nextval INTO var_seq FROM dual;
  
    -- сама загрузка
    l_all;
  
    -- теперь анализ лога на наличие ошибок
    FOR r IN (SELECT l.message
                FROM fc_dm_log l
               WHERE l.message_id BETWEEN var_seq AND pvar_last_log_line
                 AND (l.message_type = 'E' OR l.message LIKE '%ORA-%' OR l.message LIKE '%error%' OR
                     l.message LIKE '%ошибк%' OR l.message LIKE '%FAILED%')
               ORDER BY l.message_id)
    LOOP
      var_err_ret := var_err_ret || chr(13) || chr(10) || r.message;
      EXIT WHEN length(var_err_ret) > 1000;
    END LOOP;
  
    IF var_err_ret IS NOT NULL
    THEN
      RETURN 'При загрузке данных в хранилище произошли ошибки. Обратитесь к администратору хранилища:' || chr(13) || chr(10) || var_err_ret;
    END IF;
  
    RETURN 'Данные в хранилище загружены успешно.';
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.l_all_custom error:');
      pra_log_time(SQLERRM(SQLCODE));
  END l_all_custom;

  --
  -- Универсальная процедура проверки данных
  -- на то, что все коды размерностей в факте преставлены в самих размерностях
  -- Пока умеет анализировать названия колонок по умолчанию только для владельца пакета
  --
  -- Параметры:
  --  par_fact_name -- таблица-факт
  --  par_dim_names -- массив названий размерностей
  --  par_dim_cols  -- массив названий PK в размерности
  --  par_fact_cols -- массив названий колонок факта
  --    Само собой, количество элементов в массивах должно совпадать
  --    Элементы массива могут быть null, тогда имена столбцов определяются так:
  --    - для размерностей они определяются по индексу _PK (там должно быть одно поле)
  --    - для факта совпадает с названием в размерности
  --
  -- Пример вызова:
  --DECLARE
  --  vv BOOLEAN;
  --BEGIN
  --  vv := pck_load.check_fact_uni(
  --    par_fact_name => 'fc_deals_ore',
  --    par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_gtps', 'dm_ore_zones'),
  --    par_fact_cols => acpdba.type_tab_char2000('period_id',  'date_id',  'time_id', 'gtp_id',  'ore_zone_id'),
  --    par_dim_cols  => acpdba.type_tab_char2000('period_id',  'date_id',  'time_id', 'gtp_id',  'ore_zone_id')
  --  );
  --  -- или так
  --  vv := pck_load.check_fact_uni(
  --    par_fact_name => 'fc_deals_ore',
  --    par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_gtps', 'dm_ore_zones'),
  --    par_fact_cols => acpdba.type_tab_char2000('',  '',  '', '',  ''),
  --    par_dim_cols  => acpdba.type_tab_char2000('',  '',  '', '',  '')
  --  );
  --END;
  --
  /*
  FUNCTION check_fact_uni(
    par_fact_name VARCHAR2,
    par_dim_names acpdba.type_tab_char2000,
    par_dim_cols  acpdba.type_tab_char2000,
    par_fact_cols acpdba.type_tab_char2000
  ) RETURN BOOLEAN
  IS
    var_dim_cols  acpdba.type_tab_char2000 := acpdba.type_tab_char2000();
    var_fact_cols acpdba.type_tab_char2000 := acpdba.type_tab_char2000();
  
    var_count PLS_INTEGER;
  
    var_decode  VARCHAR2(2000) := 'decode(rn';
    var_select  VARCHAR2(2000) := 'SELECT COUNT(1) cnt_ok';
    var_from    VARCHAR2(2000) := 'FROM '||par_fact_name||' T0,';
    var_where   VARCHAR2(2000) := 'WHERE ';
    var_fin_select  VARCHAR2(2000);
  
    var_res_rn  ACPDBA.type_tab_number;
    var_res_ok  ACPDBA.type_tab_number;
    var_res_dim ACPDBA.type_tab_number;
  BEGIN
    pra_log_time('checking '||par_fact_name||'...');
  
    IF par_dim_names.COUNT != par_dim_cols.COUNT OR par_dim_names.COUNT != par_fact_cols.COUNT THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не совпадает количество полей во входных массивах');
    END IF;
  
    var_count := par_dim_names.COUNT;
    var_dim_cols.extend(var_count);
    var_fact_cols.extend(var_count);
    -- определим названия колонок по умолчанию
    -- сначала размерности
    -- ! PK размерности - всегда первая колонка!
    FOR i IN 1..var_count LOOP
      IF par_dim_cols(i) IS NULL THEN
        -- определим его
        BEGIN
          SELECT ic.column_name
            INTO var_dim_cols(i)
            FROM all_tab_columns ic
           WHERE ic.owner = 'IRAO_STAR' AND
                 ic.table_name = UPPER(par_dim_names(i)) AND
                 ic.column_id = 1;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Не удалось определить имя столбца по умолчанию для '||
              par_dim_names(i)||': '||SQLERRM(SQLCODE)
            );
        END;
      ELSE
        var_dim_cols(i) := par_dim_cols(i);
      END IF;
    END LOOP;
    -- теперь факт
    FOR i IN 1..var_count LOOP
      IF par_fact_cols(i) IS NULL THEN
        var_fact_cols(i) := var_dim_cols(i);
      ELSE
        var_fact_cols(i) := par_fact_cols(i);
      END IF;
    END LOOP;
  
    FOR i IN 1..var_count LOOP
      var_decode := var_decode||','||i||',c_T'||i;
      var_select := var_select||',COUNT(T'||i||'.'||var_dim_cols(i)||') c_T'||i;
      var_from   := var_from||par_dim_names(i)||' T'||i||',';
      var_where  := var_where||'T'||i||'.'||var_dim_cols(i)||'(+)=T0.'||var_fact_cols(i)||' AND ';
    END LOOP;
    -- подрежем хвосты
    var_decode := var_decode||')';
    var_from := SUBSTR(var_from, 1, LENGTH(var_from) - 1);
    var_where := SUBSTR(var_where, 1, LENGTH(var_where) - 5);
  
    var_fin_select :=
      'SELECT rn,cnt_ok,'||var_decode||' cnt_dim FROM ('||
      var_select||' '||var_from||' '||var_where||') S1,'||
      '(SELECT ROWNUM-1 rn FROM dual CONNECT BY ROWNUM <= '||(var_count+1)||') S2 '||
      'WHERE rn = 0 or cnt_ok != '||var_decode||
      ' ORDER BY rn';
  
  --  pra_log(var_fin_select);
  
    -- теперь запустим
    EXECUTE IMMEDIATE var_fin_select
    BULK COLLECT INTO var_res_rn, var_res_ok, var_res_dim;
  
    -- внимание, мы получили строк на 1 больше, чем теоретически могли
    -- это строка - с номером 0, она нужна для определения кол-ва строк в факте
    IF SQL%ROWCOUNT = 1 THEN
      -- все отлично
      pra_log_time(par_fact_name||': OK ('||var_res_ok(1)||' строк проверено)');
      RETURN TRUE;
    END IF;
  
    -- раз мы тут, значит не все в порядке в гадском королевстве
    -- Пробежимся и расскажем, что к чему
    FOR i IN 2..var_res_rn.COUNT LOOP
      pra_log_time('CHECK '||par_fact_name||': обнаружены '||(var_res_ok(i)-var_res_dim(i))||' строк '||var_fact_cols(var_res_rn(i))||', отсутствующие в '||par_dim_names(var_res_rn(i)), 'E');
      pra_log(var_fin_select);
    END LOOP;
  
    pra_log_time('check_fact_uni: '||par_fact_name||' FAILED');
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.check_fact_uni error:', 'E');
      pra_log_time(SQLERRM(SQLCODE), 'E');
      RETURN FALSE;
  END check_fact_uni;
  */

  --------------------------------------------------------------------
  /*
  PROCEDURE check_load_all
  IS
    var_flag_ok BOOLEAN := TRUE;
  BEGIN
    -- pre факты
    pra_log_time('---- Checking pre facts...');
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_fact_oper_expimp',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_gtps', 'dm_contracts', 'dm_companies', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_fact_expimp',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_contracts', 'dm_parameters'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_fact_ore',
             par_dim_names => acpdba.type_tab_char2000('dm_contracts', 'dm_contracts', 'dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_parameters', 'dm_deal_types', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('',  'contract_id2', '', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',             '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_plan_expimp',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_contracts', 'dm_companies', 'dm_parameters'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_plan_ore',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_contracts', 'dm_parameters'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_fact_oresdd',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_contracts', 'dm_deal_types', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_finobligation',
             par_dim_names => acpdba.type_tab_char2000('dm_dates',             'dm_dates',           'dm_dates',          'dm_gtps', 'dm_contracts', 'dm_deal_types', 'dm_passports', 'dm_companies', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('period_start_date_id', 'period_end_date_id', 'obligation_date_id',  '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_finpayments',
             par_dim_names => acpdba.type_tab_char2000('dm_dates',             'dm_dates',           'dm_dates',           'dm_dates', 'dm_gtps', 'dm_contracts', 'dm_deal_types', 'dm_passports', 'dm_companies', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('period_start_date_id', 'period_end_date_id', 'obligation_date_id', 'payment_date_id', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_rd_payshedules',
             par_dim_names => acpdba.type_tab_char2000('dm_dates',             'dm_dates',           'dm_dates', 'dm_gtps', 'dm_contracts', 'dm_deal_types', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('period_start_date_id', 'period_end_date_id', 'obligation_date_id', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_invoices',
             par_dim_names => acpdba.type_tab_char2000('dm_payment_docs', 'dm_periods', 'dm_dates', 'dm_gtps', 'dm_contracts', 'dm_passports', 'dm_companies', 'dm_deal_types', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('invoice_id', '',  '', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('',           '',  '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_plan_power',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_contracts', 'dm_companies', 'dm_deal_types', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('', '',  '', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '',  '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    -- !!! Тут особенность. time_zones не проверяем ,т.к. цены грузятся из странных
    --     источников и могут содержать отсутствующие часы
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_prices_ore_ffact',
             par_dim_names => acpdba.type_tab_char2000('dm_dates', 'dm_time', 'dm_gtps', 'dm_deal_types', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('', '',  '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '',  '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'pre_fc_mod_seans',
             par_dim_names => acpdba.type_tab_char2000('dm_dates', 'dm_time', 'dm_time_zones', 'dm_contracts', 'dm_gtps', 'dm_deal_types', 'dm_ore_zones', 'dm_mod_seanses'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    -------------------------------------------------------------------------------------------------------
    -- настоящие факты
    pra_log_time('---- Checking facts...');
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_deals_ore',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('',  '',  '', '',  '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',  '', '',  '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_rgb_hour',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_contracts', 'dm_gtps', 'dm_deal_types', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('',  '',  '', '',  '',  '',  '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',  '', '',  '',  '',  '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_hour_deliveries',
             par_dim_names => acpdba.type_tab_char2000('dm_contracts', 'dm_contracts', 'dm_periods', 'dm_dates', 'dm_time', 'dm_time_zones', 'dm_gtps', 'dm_ore_zones'),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',              '', '',  '',  '',  '', ''),
             par_fact_cols => acpdba.type_tab_char2000('',  'contract_id2',  '', '',  '',  '',  '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_deliveries',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_gtps', 'dm_contracts', 'dm_parameters', 'dm_companies', 'dm_passports', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('',  '',  '', '',  '',  '',  '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',  '', '',  '',  '',  '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_fin_results',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_gtps', 'dm_contracts', 'dm_parameters', 'dm_deal_types'),
             par_fact_cols => acpdba.type_tab_char2000('',  '',  '', '',  ''),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',  '', '',  '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    -- !!! Тут особенность. time_zones не проверяем ,т.к. цены грузятся из странных
    --     источников и могут содержать отсутствующие часы
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_pop_shedules',
             par_dim_names => acpdba.type_tab_char2000('dm_periods', 'dm_dates', 'dm_time', 'dm_contracts', 'dm_gtps'),
             par_fact_cols => acpdba.type_tab_char2000('',  '',  '', '',  ''),
             par_dim_cols  => acpdba.type_tab_char2000('',  '',  '', '',  '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_oresactions',
             par_dim_names => acpdba.type_tab_char2000('dm_dates',             'dm_dates',           'dm_dates',           'dm_dates', 'dm_gtps', 'dm_contracts', 'dm_deal_types', 'dm_passports', 'dm_companies', 'dm_parameters', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('period_start_date_id', 'period_end_date_id', 'obligation_date_id', 'payment_date_id', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    -- !!! Тут особенность. time_zones не проверяем ,т.к. цены грузятся из странных
    --     источников и могут содержать отсутствующие часы
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_prices_ore',
             par_dim_names => acpdba.type_tab_char2000('dm_dates', 'dm_time', 'dm_gtps', 'dm_ore_zones'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    -- !!! Тут особенность. time_zones не проверяем ,т.к. цены грузятся из странных
    --     источников и могут содержать отсутствующие часы
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_fact_prices_ore',
             par_dim_names => acpdba.type_tab_char2000('dm_dates', 'dm_time', 'dm_gtps', 'dm_ore_zones', 'dm_deal_types'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_fact_uni(
             par_fact_name => 'fc_mod_seances',
             par_dim_names => acpdba.type_tab_char2000('dm_dates', 'dm_time', 'dm_time_zones', 'dm_contracts', 'dm_gtps', 'dm_deal_types', 'dm_ore_zones', 'dm_mod_seanses'),
             par_fact_cols => acpdba.type_tab_char2000('', '', '', '', '', '', '', ''),
             par_dim_cols  => acpdba.type_tab_char2000('', '', '', '', '', '', '', '')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF var_flag_ok THEN
      pra_log_time(' check: all OK');
    ELSE
      pra_log_time(' !!! check failed', 'E');
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.check_load_all error:', 'E');
      pra_log_time(SQLERRM(SQLCODE), 'E');
  END check_load_all;
  */

  --
  -- Универсальная процедура проверки данных на уникальность по логическому PK
  --  (проблема в том, что по многим таблицам физического нет, т.к. они - вьюхи)
  --
  -- Параметры:
  --  par_tab_name  -- название таблицы
  --  par_col_names -- список колонок-ПК
  --
  /*
  FUNCTION check_factPK_uni(
    par_tab_name  VARCHAR2,
    par_col_names acpdba.type_tab_char2000
  ) RETURN BOOLEAN
  IS
    var_count PLS_INTEGER;
  
    var_select   VARCHAR2(2000) := 'SELECT COUNT(*) FROM (SELECT COUNT(*) FROM '||par_tab_name;
    var_group_by VARCHAR2(2000) := ' GROUP BY ';
    var_having   VARCHAR2(2000) := ' HAVING COUNT(*) > 1)';
    var_fin_select  VARCHAR2(2000);
  
    var_res_rn  NUMBER;
  BEGIN
    pra_log_time('checking PK for '||par_tab_name||'...');
  
    var_count := par_col_names.COUNT;
    -- добавим все поля ПК в группировку
    FOR i IN 1..var_count LOOP
      var_group_by := var_group_by||par_col_names(i)||',';
    END LOOP;
    -- подрежем хвосты
    var_group_by := SUBSTR(var_group_by, 1, LENGTH(var_group_by) - 1);
  
    var_fin_select := var_select||var_group_by||var_having;
  --  pra_log(var_fin_select);
  
    -- теперь запустим, получим количество дубликатов
    EXECUTE IMMEDIATE var_fin_select
    INTO var_res_rn;
  
    -- если 0 - это хорошо
    IF var_res_rn = 0 THEN
      -- все отлично
      pra_log_time(par_tab_name||': PK OK');
      RETURN TRUE;
    END IF;
  
    -- раз мы тут, значит не все в порядке в гадском королевстве
    pra_log_time('CHECK '||par_tab_name||': обнаружено '||var_res_rn||' дублирующихся значений в PK', 'E');
    pra_log(var_fin_select);
  
    pra_log_time('check_factPK_uni: '||par_tab_name||' FAILED');
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.check_factPK_uni error:', 'E');
      pra_log_time(SQLERRM(SQLCODE), 'E');
      RETURN FALSE;
  END check_factPK_uni;
  
  --
  -- проверить ПК по всем размерностям и фактам
  --
  PROCEDURE check_loadPK_all
  IS
    var_flag_ok BOOLEAN := TRUE;
  BEGIN
    -- размерности
    pra_log_time('---- Checking dm...');
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_companies',
             par_col_names => acpdba.type_tab_char2000('company_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_contracts',
             par_col_names => acpdba.type_tab_char2000('contract_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_dates',
             par_col_names => acpdba.type_tab_char2000('date_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_deal_types',
             par_col_names => acpdba.type_tab_char2000('deal_type_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_gtps',
             par_col_names => acpdba.type_tab_char2000('gtp_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_ore_zones',
             par_col_names => acpdba.type_tab_char2000('ore_zone_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_parameters',
             par_col_names => acpdba.type_tab_char2000('parameter_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_passports',
             par_col_names => acpdba.type_tab_char2000('passport_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_payment_docs',
             par_col_names => acpdba.type_tab_char2000('document_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_periods',
             par_col_names => acpdba.type_tab_char2000('period_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_regions',
             par_col_names => acpdba.type_tab_char2000('region_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_time',
             par_col_names => acpdba.type_tab_char2000('time_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
    IF NOT pck_load.check_factPK_uni(
             par_tab_name  => 'dm_time_zones',
             par_col_names => acpdba.type_tab_char2000('timez_id')
           )
    THEN var_flag_ok := FALSE; END IF;
  
  
  -- фактов пока нету, и, возможно не будет
  
    IF var_flag_ok THEN
      pra_log_time(' checkPK: all OK');
    ELSE
      pra_log_time(' !!! checkPK failed', 'E');
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      pra_log_time('pck_load.check_loadPK_all error:', 'E');
      pra_log_time(SQLERRM(SQLCODE), 'E');
  END check_loadPK_all;
  */

  PROCEDURE exec_proc(par_proc VARCHAR2) IS
    var_proc CONSTANT VARCHAR2(2000) := upper(par_proc);
    --  var_sql   VARCHAR2(2000);
  BEGIN
    pra_log_time('proc ' || var_proc || ' => REFRESH');
    SAVEPOINT start_proc;
    EXECUTE IMMEDIATE 'begin ' || var_proc || '; end;';
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO start_proc;
      pra_log_time('pck_load.exec_proc(' || par_proc || ') error:', 'E');
      pra_log_time(SQLERRM(SQLCODE));
    
  END exec_proc;

  PROCEDURE l_dm_p_pol_header IS
    res_flag    NUMBER;
    vt_commands ins.tt_one_col;
  BEGIN
    /* Отключение всех индексов */
    FOR vr_idx IN (SELECT i.drop_index_text
                     FROM ins_dwh.t_indexes i
                    WHERE i.table_name = 'DM_P_POL_HEADER'
                      AND i.index_name IN (SELECT ai.index_name
                                             FROM all_indexes ai
                                            WHERE ai.table_name = i.table_name
                                              AND ai.owner = 'INS_DWH'))
    LOOP
      BEGIN
        EXECUTE IMMEDIATE vr_idx.drop_index_text;
      EXCEPTION
        WHEN OTHERS THEN
          pra_log_time(vr_idx.drop_index_text || ' failed');
      END;
    END LOOP;
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE dm_p_pol_header';
  
    res_flag := 1;
  
    INSERT /*+ APPEND */
    INTO ins_dwh.dm_p_pol_header
      (policy_header_id
      ,ids
      ,pol_num
      ,policy_serial
      ,policy_number
      ,insurer
      ,prod_desc
      ,prod_brief
      ,start_date
      ,end_date
      ,fund
      ,notice_num
      ,is_group_flag
      ,status
      ,sales_channel_id
      ,pay_term
      ,coll_method
      ,agency
      ,AGENT
      ,agent_category
      ,agent_leader
      ,leader_category
      ,last_ver_stat
      ,sign_date
      ,insurer_contact_id
      ,first_pay_date_pd4
      ,max_pay_term
      ,is_converted
      ,decline_date
      ,decline_type_id
      ,decline_reason_id
      ,min_to_pay_date
      ,agent_header_id
      ,policy_form_name
      ,nbv_koef_for_commiss
      , --Чирков/165428/
       description
      ,agent_recruit
      ,is_tech_work --Чирков/192022/
      ,product_group_name
      ,min_nonpay_per
      ,dept_number --Чирков 325154: FW: Контроль начислений   
      ,is_handchange)
      SELECT ph.policy_header_id
            ,ph.ids
            ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) pol_num
            ,p.pol_ser policy_serial
            ,p.pol_num policy_number
            ,c.obj_name insurer
            ,prod.description prod_desc
            ,prod.brief prod_brief
            ,ph.start_date start_date
            ,p.end_date end_date
            ,f.brief fund
            ,decode(p.notice_ser, NULL, p.notice_num, p.notice_ser || '-' || p.notice_num) notice_num
            ,nvl(p.is_group_flag, 0) is_group_flag
            ,ins.doc.get_doc_status_name(p.policy_id, to_date('01.01.2999', 'dd.mm.yyyy')) status
            ,nvl(ach.t_sales_channel_id, ph.sales_channel_id) sales_channel_id
            ,pt.description pay_term
            ,cm.description coll_method
            ,ins.ent.obj_name('DEPARTMENT', ach.agency_id) agency
            ,ins.ent.obj_name('CONTACT', ach.agent_id) AGENT
            ,ins.ent.obj_name('AG_CATEGORY_AGENT', ach.category_id) agent_cat
            ,ins.ent.obj_name('CONTACT'
                             ,(SELECT ach_lead.agent_id
                                FROM ins.ag_contract_header ach_lead
                                    ,ins.ag_contract        ac_lead
                               WHERE ach_lead.ag_contract_header_id = ac_lead.contract_id
                                 AND ac_lead.ag_contract_id = ach.contract_leader_id)) agent_leader
            ,ins.ent.obj_name('AG_CATEGORY_AGENT'
                             ,(SELECT ac_lead2.category_id
                                FROM ins.ag_contract_header ach_lead
                                    ,ins.ag_contract        ac_lead
                                    ,ins.ag_contract        ac_lead2
                               WHERE ach_lead.ag_contract_header_id = ac_lead.contract_id
                                 AND ac_lead2.ag_contract_id = ach_lead.last_ver_id
                                 AND ac_lead.ag_contract_id = ach.contract_leader_id)) leader_category
            ,ins.doc.get_doc_status_name(last_version.policy_id, to_date('01.01.2999', 'dd.mm.yyyy')) last_ver_stat
            ,
             --       , decode(charged_ape_policy.policy_header_id, null, 0,1) is_charged,
             p.sign_date
            ,insurers.contact_id insurer_contact_id
            ,first_pd4_date.due_date first_pay_date_pd4
            ,max_pt.pay_term_desc
            ,decode(p.ext_id, NULL, 0, 1)
            ,last_version.decline_date decline_date
            ,nvl(last_version.decline_type_id, -1) decline_type_id
            ,nvl(last_version.decline_reason_id, -1) decline_reason_id
            ,
             /*(SELECT min(epg.plan_date)
              FROM ins.p_policy pp,
                   ins.doc_doc dd,
                   ins.ven_ac_payment epg,
                   ins.doc_templ dt,
                   ins.doc_set_off dso
             WHERE pp.pol_header_id = ph.policy_header_id
               AND dd.parent_id = pp.policy_id
               AND dd.child_id = epg.payment_id
               AND epg.doc_templ_id = dt.doc_templ_id
               AND dt.brief = 'PAYMENT'
               AND epg.payment_id = dso.parent_doc_id (+)
               AND dso.cancel_date IS NULL
               AND ins.doc.get_doc_status_brief(epg.payment_id) = 'TO_PAY'
               AND (epg.amount - nvl(dso.set_off_child_amount,0)) >= 400)*/
             -- Байтин А.
             (SELECT MIN(epg.plan_date)
                FROM ins.p_policy       pp
                    ,ins.doc_doc        dd
                    ,ins.ven_ac_payment epg
                    ,ins.doc_templ      dt
                    ,ins.document       dc
                    ,ins.doc_status_ref dsr
               WHERE pp.pol_header_id = ph.policy_header_id
                 AND dd.parent_id = pp.policy_id
                 AND dd.child_id = epg.payment_id
                 AND epg.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT'
                 AND epg.payment_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'TO_PAY'
                 AND (epg.amount - (SELECT nvl(SUM(dso.set_off_child_amount), 0)
                                      FROM ins.doc_set_off dso
                                     WHERE dso.parent_doc_id = epg.payment_id
                                       AND dso.cancel_date IS NULL)) >= 400) min_to_pay_date
            ,ach.ag_contract_header_id agent_header_id
            ,tpf.t_policy_form_name
             --Чирков/165428 Разработка - новый элемент факта договор страхования/
             --,ins.pkg_tariff_calc.calc_coeff_val('nbv_koef_for_commiss', ins.t_number_type(ph.policy_header_id)) nbv_koef_for_commiss
            ,(SELECT tpc.val
                FROM ins.t_prod_coef      tpc
                    ,ins.t_prod_coef_type tpct
               WHERE tpct.t_prod_coef_type_id = tpc.t_prod_coef_type_id
                 AND tpct.brief = 'nbv_koef_for_commiss'
                 AND tpc.criteria_1 = ph.policy_header_id
                 AND rownum = 1) AS nbv_koef_for_commiss
             --/end_Чирков/165428/
            ,ph.description
            ,ins.ent.obj_name('CONTACT'
                             ,(SELECT ach_rec.agent_id
                                FROM ins.ag_contract_header ach_rec
                                    ,ins.ag_contract        ac_rec
                               WHERE ach_rec.ag_contract_header_id = ac_rec.contract_id
                                 AND ac_rec.ag_contract_id = ach.contract_recrut_id)) agent_recruit
             --Чирков /192022 Доработка АС BI в части обеспечения регистрации 
            ,CASE
               WHEN EXISTS (SELECT 1
                       FROM ins.ven_journal_tech_work jtw
                           ,ins.doc_status_ref        dsr
                      WHERE jtw.doc_status_ref_id = dsr.doc_status_ref_id
                        AND jtw.policy_header_id = ph.policy_header_id
                        AND dsr.brief = 'CURRENT'
                        AND jtw.work_type = 0) THEN
                1
               ELSE
                0
             END
             --Чирков /192022// 
             
            ,decode(prod.brief
                   ,'GN'
                   ,CASE
                      WHEN nvl(ach.ag_sc_brief, chn.brief) = 'BANK' THEN
                       'Group Credit life'
                      WHEN 1 =
                           (SELECT COUNT(1)
                              FROM dual
                             WHERE EXISTS
                             (SELECT NULL
                                      FROM ins.p_policy           pp
                                          ,ins.p_pol_header       ph
                                          ,ins.as_asset           aa
                                          ,ins.p_cover            pc
                                          ,ins.t_prod_line_option plo
                                          ,ins.t_product_line     pl
                                          ,ins.t_lob_line         ll
                                     WHERE pp.pol_header_id = ph.policy_header_id
                                       AND pp.policy_id = aa.p_policy_id
                                       AND aa.as_asset_id = pc.as_asset_id
                                       AND pc.t_prod_line_option_id = plo.id
                                       AND plo.product_line_id = pl.id
                                       AND pp.policy_id = p.policy_id
                                       AND ll.t_lob_line_id = pl.t_lob_line_id
                                       AND ll.description IN
                                           ('Программа №1 Смешанное страхование жизни'
                                           ,'Программа №4 Дожитие с возвратом взносов в случае смерти'))) THEN
                       'Group END'
                      ELSE
                       'Group Term/PA'
                    END
                   ,pg.name) AS product_group_name
            ,(SELECT MIN(epg.grace_date)
                FROM ins.p_policy       pp
                    ,ins.doc_doc        dd
                    ,ins.ven_ac_payment epg
                    ,ins.doc_templ      dt
                    ,ins.document       dc
                    ,ins.doc_status_ref dsr
               WHERE pp.pol_header_id = ph.policy_header_id
                 AND dd.parent_id = pp.policy_id
                 AND dd.child_id = epg.payment_id
                 AND epg.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT'
                 AND epg.payment_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'TO_PAY'
                 AND (epg.amount - (SELECT nvl(SUM(dso.set_off_child_amount), 0)
                                      FROM ins.doc_set_off dso
                                     WHERE dso.parent_doc_id = epg.payment_id
                                       AND dso.cancel_date IS NULL)) >= 400) min_nonpay_per --322038: Минимальный срок неоплаты
            ,(SELECT to_char(sh.universal_code, 'FM0009')
                FROM ins.sales_dept_header sh
                    ,ins.department        dp
               WHERE sh.organisation_tree_id = dp.org_tree_id
                 AND dp.department_id = ach.agency_id) dept_number --Чирков 325154: FW: Контроль начислений                                      
            ,tpt.is_handchange /*Для отображения признака "Ручной ввод" Черных М. 4.2.2015 Прекращение (Отчет "DWH_отчет о неоплатах_анализ неплат_2011 старые ПУ")*/
        FROM ins.p_pol_header ph
            ,ins.ven_p_policy p
            ,
             -- максимальная периодичность оплаты по договору
             (SELECT t.pol_header_id
                    ,t.pay_term_desc
                    ,t.pay_term_id
                FROM (SELECT pp.pol_header_id
                            ,pt.description pay_term_desc
                            ,pt.id pay_term_id
                            ,row_number() over(PARTITION BY pp.pol_header_id ORDER BY decode(pt.description, 'Ежеквартально', 3, 'Раз в полгода', 6, 'Ежегодно', 12, 'Единовременно', 10000, 'Ежемесячно', 1, 0) DESC) rn
                        FROM ins.p_policy        pp
                            ,ins.t_payment_terms pt
                       WHERE pp.payment_term_id = pt.id) t
               WHERE rn = 1) max_pt
            ,ins.t_collection_method cm
            ,(SELECT pc.policy_id
                    ,pc.contact_id
                FROM ins.p_policy_contact pc
               WHERE pc.contact_policy_role_id = 6) insurers
            ,ins.contact c
            ,ins.t_payment_terms pt
            ,ins.fund f
            ,ins.t_product prod
            ,ins.t_product_group pg
            ,ins.t_policyform_product tpp
            ,ins.t_policy_form tpf
            ,ins.t_sales_channel chn
            ,(SELECT *
                FROM (SELECT ach.agency_id
                            ,ach.ag_contract_header_id
                            ,ach.agent_id
                            ,c.obj_name
                            ,ach.t_sales_channel_id
                            ,ac.contract_leader_id
                            ,ac.contract_recrut_id
                            ,ac.category_id
                            ,pad.policy_header_id
                            ,pad.date_begin
                            ,row_number() over(PARTITION BY pad.policy_header_id ORDER BY pad.date_begin DESC) rn
                            ,agsc.brief ag_sc_brief
                        FROM ins.p_policy_agent_doc pad
                            ,ins.ag_contract_header ach
                            ,ins.ag_contract        ac
                            ,ins_dwh.dm_contact     c
                            ,ins.t_sales_channel    agsc
                       WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                         AND ac.ag_contract_id =
                             ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                         AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                         AND c.contact_id = ach.agent_id
                         AND agsc.id = ach.t_sales_channel_id) t
               WHERE t.rn = 1) ach
            ,(SELECT t.due_date
                    ,t.pol_header_id
                FROM (SELECT pay_doc.due_date
                            ,pp.pol_header_id
                            ,row_number() over(PARTITION BY pp.pol_header_id ORDER BY plan_doc.plan_date, pay_doc.due_date) r
                        FROM ins.ven_ac_payment plan_doc
                            ,ins.doc_templ      dt
                            ,ins.doc_doc        dd
                            ,ins.p_policy       pp
                            ,ins.doc_set_off    dso
                            ,ins.ven_ac_payment pay_doc
                       WHERE 1 = 1
                         AND plan_doc.doc_templ_id = dt.doc_templ_id
                         AND dt.brief = 'PAYMENT'
                         AND dso.parent_doc_id = plan_doc.payment_id
                         AND dso.child_doc_id = pay_doc.payment_id
                         AND dd.parent_id = pp.policy_id
                         AND dd.child_id = plan_doc.payment_id
                         AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') t
               WHERE t.r = 1) first_pd4_date
             /* 386031 Григорьев Ю. Не учитываем отмененные версии */
            ,(SELECT p.pol_header_id
                    ,p.version_num
                    ,p.decline_date
                    ,p.decline_type_id
                    ,p.decline_reason_id
                    ,p.policy_id
                FROM ins.p_pol_header ph
                    ,ins.p_policy     p
               WHERE ph.policy_header_id = p.pol_header_id
                 AND ph.max_uncancelled_policy_id = p.policy_id) last_version
            ,ins.t_policyform_product tpt /*Для отображения признака "Ручной ввод" Черных М. 4.2.2015 Прекращение*/
      /**/
      /*    ,
             --полисы, по которым есть начисления APE
             (select p.pol_header_id policy_header_id
                        from ins.trans    t,
                             ins.p_cover  pc,
                             ins.as_asset a,
                             ins.p_policy p
                       where t.obj_uro_id = pc.p_cover_id
                         and pc.as_asset_id = a.as_asset_id
                         and a.p_policy_id = p.policy_id
                         and t.trans_templ_id = 621
      group by p.pol_header_id) charged_ape_policy
      */
      
       WHERE ph.policy_id = p.policy_id
         AND ph.policy_header_id = ach.policy_header_id(+)
         AND p.payment_term_id = pt.id
         AND ph.policy_header_id = max_pt.pol_header_id(+)
         AND cm.id = p.collection_method_id
         AND insurers.policy_id = p.policy_id
         AND insurers.contact_id = c.contact_id
         AND ph.product_id = prod.product_id
         AND prod.t_product_group_id = pg.t_product_group_id(+)
         AND ph.fund_id = f.fund_id
         AND first_pd4_date.pol_header_id(+) = ph.policy_header_id
         AND ph.policy_header_id = last_version.pol_header_id(+)
            /**/
         AND p.t_product_conds_id = tpp.t_policyform_product_id(+)
         AND tpp.t_policy_form_id = tpf.t_policy_form_id(+)
         AND ph.sales_channel_id = chn.id
         AND p.t_product_conds_id = tpt.t_policyform_product_id(+)
      -- and ph.ids = 2010002515
      
      UNION ALL
      SELECT -1 policy_header_id
            ,NULL
            ,'неопределен' pol_num
            ,'неопределен' policy_serial
            ,'неопределен' policy_number
            ,'неопределен' insurer
            ,'неопределен' prod_desc
            ,'неопределен' prod_brief
            ,NULL start_date
            ,NULL end_date
            ,'' fund
            ,'неопределен' notice_num
            ,NULL is_group_flag
            ,'неопределен' status
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
             
             --       , 0 is_charged
            ,NULL sign_date
            ,-1 insurer_contact_id
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,-1
            ,-1
            ,NULL
            ,-1
            ,'неопределен'
            ,NULL nbv_koef_for_commiss --Чирков/165428/
            ,NULL
            ,'неопределен'
            ,NULL
            ,'неопределен' product_group_name --Чирков 223879: FW: Справочник <Линии бизнеса для отчетности>
            ,NULL
            ,NULL dept_number
            ,NULL is_handchange
        FROM dual;
    /* Включение всех индексов */
    FOR vr_idx IN (SELECT i.create_index_text
                     FROM ins_dwh.t_indexes i
                    WHERE i.table_name = 'DM_P_POL_HEADER')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE vr_idx.create_index_text;
      EXCEPTION
        WHEN OTHERS THEN
          pra_log_time(vr_idx.create_index_text || ' => failed');
      END;
    END LOOP;
  
    /* Сбор статистики */
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'DM_P_POL_HEADER', cascade => TRUE);
  END;

  PROCEDURE l_t_fc_epg IS
  BEGIN
    /* Отключение всех индексов */
    FOR vr_idx IN (SELECT i.drop_index_text
                     FROM ins_dwh.t_indexes i
                    WHERE i.table_name = 'T_FC_EPG'
                      AND i.index_name IN (SELECT ai.index_name
                                             FROM all_indexes ai
                                            WHERE ai.table_name = i.table_name
                                              AND ai.owner = 'INS_DWH'))
    LOOP
      BEGIN
        EXECUTE IMMEDIATE vr_idx.drop_index_text;
      EXCEPTION
        WHEN OTHERS THEN
          pra_log_time(vr_idx.drop_index_text || ' failed');
      END;
    END LOOP;
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE t_fc_epg';
  
    INSERT /*+ APPEND*/
    INTO t_fc_epg
      (payment_id
      ,pol_header_id
      ,coll_method
      ,plan_date
      ,due_date
      ,grace_date
      ,num
      ,epg_status
      ,first_epg
      ,epg_amount_rur
      ,epg_amount
      ,pay_date
      ,set_of_amt_rur
      ,set_of_amt
      ,hold_amt_rur
      ,hold_amt
      ,agent_id
      ,agent_ad_id
      ,agent_stat
      ,agent_agency
      ,manager_id
      ,manager_ad_id
      ,manager_stat
      ,manager_agency
      ,dir_id
      ,dir_ad_id
      ,dir_stat
      ,dir_agency
      ,epg_num
      ,agent_agency_id
      ,index_fee
      ,addendum_type)
    
      SELECT payment_id
            ,pol_header_id
            ,e.coll_method
            ,plan_date
            ,e.due_date
            ,e.grace_date
            ,num
            ,epg_status
            ,first_epg
            ,e.epg_amount_rur
            ,e.epg_amount
            ,e.pay_date
            ,e.set_of_amt_rur
            ,e.set_of_amt
            ,e.hold_amt_rur
            ,e.hold_amt
            ,e.agent_id
            ,e.agent_ad_id
            ,e.agent_stat
            ,nvl(nvl(e.agent_agency, e.manager_agency), e.dir_agency)
            ,e.manager_id
            ,e.manager_ad_id
            ,e.manager_stat
            ,e.manager_agency
            ,e.dir_id
            ,e.dir_ad_id
            ,e.dir_stat
            ,e.dir_agency
            ,e.epg_num
            ,nvl(a.agency_id, -1)
            ,e.index_fee
            ,e.addendum_type
      
        FROM v_epg_fact_preview e
            ,dm_agency          a
       WHERE nvl(nvl(e.agent_agency, e.manager_agency), e.dir_agency) = a.name(+);
  
    /* Включение всех индексов */
    FOR vr_idx IN (SELECT i.create_index_text FROM ins_dwh.t_indexes i WHERE i.table_name = 'T_FC_EPG')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE vr_idx.create_index_text;
      EXCEPTION
        WHEN OTHERS THEN
          pra_log_time(vr_idx.create_index_text || ' => failed');
      END;
    END LOOP;
  
    /* Сбор статистики */
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'T_FC_EPG', cascade => TRUE);
  
    MERGE INTO ins_dwh.t_fc_epg fe
    USING (SELECT fes.epg_amount_rur / SUM(fes.epg_amount_rur) over(PARTITION BY fes.plan_date, fes.pol_header_id) AS index_fee_coeff
                 ,fes.rowid AS rid
             FROM ins_dwh.t_fc_epg fes
            WHERE fes.index_fee IS NOT NULL
              AND fes.epg_amount_rur != 0
              AND fes.epg_status != 'Аннулирован') fes
    ON (fe.rowid = fes.rid)
    WHEN MATCHED THEN
      UPDATE SET fe.index_fee_prop = fe.index_fee * fes.index_fee_coeff;
    COMMIT;
  END;

  /*
    Байтин А.
    Заполнение факта ЭПГ для ХКФБ
  */
  PROCEDURE l_t_fc_epg_hkb IS
  BEGIN
    /* Отключение всех индексов */
    FOR vr_idx IN (SELECT i.drop_index_text
                     FROM ins_dwh.t_indexes i
                    WHERE i.table_name = 'T_FC_EPG_HKB'
                      AND i.index_name IN (SELECT ai.index_name
                                             FROM all_indexes ai
                                            WHERE ai.table_name = i.table_name
                                              AND ai.owner = 'INS_DWH'))
    LOOP
      BEGIN
        EXECUTE IMMEDIATE vr_idx.drop_index_text;
      EXCEPTION
        WHEN OTHERS THEN
          pra_log_time(vr_idx.drop_index_text || ' failed');
      END;
    END LOOP;
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE t_fc_epg_hkb';
  
    INSERT /*+ APPEND*/
    INTO ins_dwh.t_fc_epg_hkb
      (payment_id
      ,pol_header_id
      ,coll_method
      ,plan_date
      ,due_date
      ,grace_date
      ,num
      ,epg_status
      ,first_epg
      ,epg_amount_rur
      ,epg_amount
      ,pay_date
      ,set_of_amt_rur
      ,set_of_amt
      ,hold_amt_rur
      ,hold_amt
      ,agent_id
      ,agent_ad_id
      ,agent_stat
      ,agent_agency
      ,manager_id
      ,manager_ad_id
      ,manager_stat
      ,manager_agency
      ,dir_id
      ,dir_ad_id
      ,dir_stat
      ,dir_agency
      ,epg_num
      ,agent_agency_id)
    
      SELECT payment_id
            ,pol_header_id
            ,e.coll_method
            ,plan_date
            ,e.due_date
            ,e.grace_date
            ,num
            ,epg_status
            ,first_epg
            ,e.epg_amount_rur
            ,e.epg_amount
            ,e.pay_date
            ,e.set_of_amt_rur
            ,e.set_of_amt
            ,e.hold_amt_rur
            ,e.hold_amt
            ,e.agent_id
            ,e.agent_ad_id
            ,e.agent_stat
            ,nvl(nvl(e.agent_agency, e.manager_agency), e.dir_agency)
            ,e.manager_id
            ,e.manager_ad_id
            ,e.manager_stat
            ,e.manager_agency
            ,e.dir_id
            ,e.dir_ad_id
            ,e.dir_stat
            ,e.dir_agency
            ,e.epg_num
            ,nvl(a.agency_id, -1)
      
        FROM ins_dwh.v_epg_fact_preview_hkb e
            ,dm_agency                      a
       WHERE nvl(nvl(e.agent_agency, e.manager_agency), e.dir_agency) = a.name(+);
  
    /* Включение всех индексов */
    FOR vr_idx IN (SELECT i.create_index_text
                     FROM ins_dwh.t_indexes i
                    WHERE i.table_name = 'T_FC_EPG_HKB')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE vr_idx.create_index_text;
      EXCEPTION
        WHEN OTHERS THEN
          pra_log_time(vr_idx.create_index_text || ' => failed');
      END;
    END LOOP;
  
    /* Сбор статистики */
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'T_FC_EPG_HKB', cascade => TRUE);
    /**/
    UPDATE ins_dwh.meta_data dm
       SET dm.is_renew = 0
     WHERE TRIM(dm.type_db_object) = 'view'
       AND dm.name_db_object = 'fc_epg_hkb';
    COMMIT;
    /**/
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 04.03.2011 11:33:02
  -- Purpose : Обновление факта комиссия детали
  -- понадобилось т.к. обновление mview падает с ora-600
  PROCEDURE l_t_fc_commiss IS
    proc_name VARCHAR2(20) := 'l_t_fc_commiss';
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE FC_AG_COMMIS_DET';
  
    INSERT /*+ APPEND*/
    INTO fc_ag_commis_det
      SELECT * FROM v_ag_com_detail_preview;
  
    /* Сбор статистики */
    dbms_stats.gather_table_stats(ownname => 'INS_DWH'
                                 ,tabname => 'FC_AG_COMMIS_DET'
                                 ,cascade => TRUE);
    --Гаргонов Д.А.
    --Заявка 284706
    UPDATE ins_dwh.meta_data dm
       SET dm.is_renew = 0
     WHERE TRIM(dm.type_db_object) = 'table'
       AND dm.name_db_object = 'fc_ag_commis_det';
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END l_t_fc_commiss;

  /*PROCEDURE l_t_rl_ops
  IS
  proc_name VARCHAR2(20):='l_t_rl_ops';
  BEGIN
  
     INS.PKG_OPS_RL_FORM.PREP_RL_OPS_NEAREST_AGENT;
     INS.PKG_OPS_RL_FORM.PREP_RL_OPS_AGENT_TREE;
     INS.PKG_OPS_RL_FORM.PREP_RL_FOR_DWH;
     INS.PKG_OPS_RL_FORM.PREP_OPS_FOR_DWH;
  
     execute immediate 'TRUNCATE TABLE INS_DWH.T_DWH_RL_OPS';
  
     INSERT \*+ APPEND*\ INTO INS_DWH.T_DWH_RL_OPS
     SELECT *
     FROM INS.V_REPORT_RL_OPS_DWH;
  
  EXCEPTION
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении '||proc_name);
  END l_t_rl_ops;*/

  /** процедура апдейта поля APE в рублях по первым ЭПГ договоров (самым первым из первых ЭПГ по ID)
  * APE рассчитывается исходя из суммы проводок APE
  */
  PROCEDURE upd_t_fc_epg IS
  BEGIN
    MERGE INTO t_fc_epg e
    USING (SELECT first_epg.payment_id
                 ,first_epg.pol_header_id
                 ,ape.s ape_amount
             FROM -- первые уникальные платежи по договорам
                  (SELECT t.pol_header_id
                         ,t.payment_id
                     FROM (SELECT e.pol_header_id
                                 ,e.payment_id
                                 ,row_number() over(PARTITION BY e.pol_header_id, e.first_epg ORDER BY e.payment_id) r
                             FROM t_fc_epg e
                            WHERE e.first_epg = 1) t
                    WHERE t.r = 1) first_epg
                 ,
                  -- суммы проводок APE по договорам
                  (SELECT SUM(t.rur_amount) s
                         ,t.pol_header_id
                     FROM fc_trans t
                    WHERE 1 = 1
                      AND t.trans_templ_id = 621
                    GROUP BY t.pol_header_id) ape
            WHERE first_epg.pol_header_id = ape.pol_header_id(+)) t2
    
    ON (t2.payment_id = e.payment_id)
    
    WHEN MATCHED THEN
      UPDATE SET e.ape_amount_rur = t2.ape_amount;
  END;

  /*
    Процедура апдейта таблицы dm_p_pol_header
  */
  PROCEDURE upd_dm_p_pol_header IS
  BEGIN
    -- вычисление и апдейт максимальной даты ЭПГ по договору, находящегося в статусе "Оплачен"
    MERGE INTO dm_p_pol_header ph
    USING (SELECT t.last_plan_payed_date
                 ,t.pol_header_id
             FROM (SELECT MAX(e.plan_date) over(PARTITION BY e.pol_header_id) last_plan_payed_date
                         ,e.pol_header_id
                         ,row_number() over(PARTITION BY e.pol_header_id ORDER BY e.plan_date) rn
                     FROM t_fc_epg e
                    WHERE 1 = 1
                         -- and e.pol_header_id = 18224031
                      AND e.epg_status = 'Оплачен') t
            WHERE t.rn = 1) tt
    ON (tt.pol_header_id = ph.policy_header_id)
    
    WHEN MATCHED THEN
      UPDATE SET ph.last_plan_payed_date = tt.last_plan_payed_date;
  END;

  FUNCTION is_date
  (
    p_s      IN VARCHAR2
   ,p_format IN VARCHAR2
  ) RETURN NUMBER IS
    res NUMBER(1);
    v_d DATE;
  BEGIN
    res := 1;
    v_d := NULL;
    BEGIN
      v_d := to_date(p_s, p_format);
    EXCEPTION
      WHEN OTHERS THEN
        res := 0;
    END;
    RETURN res;
  END;

  /*
    Пиядин А.
    Процедура обновления факта "Финансовая транзакция"
    По мат.вью логу на таблице INS.TRANS отдельно обрабатываем операции вставки / апдейта / удаления
  */
  PROCEDURE l_fc_trans IS
    proc_name VARCHAR2(20) := 'l_fc_trans';
    v_seq     NUMBER;
  BEGIN
    SELECT MAX(seq) INTO v_seq FROM ins_dwh.mlog_trans;
  
    /* Сбор статистики MLOG_TRANS*/
    pra_log_time('proc ' || proc_name || ' => MLOG_TRANS GATHER STATS');
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'MLOG_TRANS', cascade => TRUE);
  
    /* Удаление измененных/удаленных транзакций */
    pra_log_time('proc ' || proc_name || ' => DELETE RECORDS FROM FC_TRANS');
    DELETE FROM ins_dwh.fc_trans
     WHERE trans_id IN (SELECT trans_id
                          FROM ins_dwh.mlog_trans
                         WHERE dmltype IN ('U', 'D')
                           AND seq <= v_seq);
  
    /* Вставка записей в хранилище */
    pra_log_time('proc ' || proc_name || ' => INSERT ROWS INTO FC_TRANS');
    INSERT /*+ APPEND */
    INTO ins_dwh.fc_trans
      WITH trans AS
       (SELECT /*+ INDEX (t IX_MLOG_TRN_SEQ)*/
         t.*
          FROM ins_dwh.mlog_trans t
              , -- Пиядин А. переведено с таблицы проводок TRANS на лог MLOG_TRANS
               (SELECT /*+ CARDINALITY (x 1) INDEX (x IX_MLOG_TRN_TRANS_id)*/
                 trans_id
                ,MAX(seq) AS max_seq
                  FROM ins_dwh.mlog_trans x
                 WHERE seq <= v_seq
                 GROUP BY trans_id) tr_max_seq
         WHERE t.seq = tr_max_seq.max_seq
           AND t.trans_id = tr_max_seq.trans_id
           AND t.dmltype <> 'D'),
      trans_cover AS
       (SELECT t.*
              ,cd.p_cover_id
              ,cc.c_claim_header_id
              ,cd.t_damage_code_id
              ,cd.c_damage_id
          FROM trans        t
              ,ins.c_damage cd
              ,ins.c_claim  cc
         WHERE cd.c_claim_id = cc.c_claim_id
           AND t.obj_ure_id = cd.ent_id
           AND t.obj_uro_id = cd.c_damage_id
        UNION ALL
        SELECT t.*
              ,obj_uro_id AS p_cover_id
              ,NULL       c_claim_header_id
              ,NULL       t_damage_code_id
              ,NULL       c_damage_id
          FROM trans t
         WHERE t.obj_ure_id = 305
        --420605
        UNION ALL
        SELECT t.*
              ,pc.p_cover_id p_cover_id
              ,NULL          c_claim_header_id
              ,NULL          t_damage_code_id
              ,NULL          c_damage_id
          FROM trans                  t
              ,ins.p_cover_decline    cd1
              ,ins.p_cover            pc
              ,ins.t_prod_line_option plo
         WHERE t.obj_ure_id = 4743
           AND t.obj_uro_id = cd1.p_cover_decline_id
           AND cd1.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = plo.id
           AND plo.product_line_id = cd1.t_product_line_id)
      SELECT q.*
            ,trunc(MONTHS_BETWEEN(least(greatest(q.trans_date, q.pol_header_start_date)
                                       ,q.pol_header_end_date)
                                 ,q.pol_header_start_date) / 12) + 1 insurance_year_number
            ,nvl(fc_a.agency_id, -1) agency_id
            ,nvl(fc_a.t_sales_channel_id, -1) t_sales_channel_id
            ,nvl(fc_a.ag_stat_agent_id, -1) ag_stat_agent_id
            ,nvl(fc_a.ag_category_agent_id, -1) ag_category_agent_id
            ,SYSDATE created_date
            ,SYSDATE modified_date
        FROM (SELECT /* +LEADING(t ) */
               t.trans_id
              ,to_number(to_char(t.trans_date, 'yyyymmdd')) date_id
              ,t.trans_date
              ,nvl(dm_tt.trans_templ_id, -1) trans_templ_id
              ,dt.num dt_num
              ,ct.num ct_num
              ,p.pol_header_id
               
              ,(SELECT pc1.contact_id
                  FROM ins.p_policy_contact pc1
                 WHERE pc1.contact_policy_role_id = 6
                   AND pc1.policy_id = p.policy_id) AS insurer_contact_id
               
              ,aa.assured_contact_id
              ,pc.t_prod_line_option_id risk_type_id
              ,(CASE
                 WHEN MONTHS_BETWEEN(p.end_date + 1, ph.start_date) > 12 THEN
                  CASE
                    WHEN ig.life_property = 1 THEN
                     2
                    WHEN ig.life_property = 0 THEN
                     4
                    ELSE
                     -1
                  END
                 ELSE
                  CASE
                    WHEN ig.life_property = 1 THEN
                     1
                    WHEN ig.life_property = 0 THEN
                     3
                    ELSE
                     -1
                  END
               END) risk_type_gaap_id
              ,t.trans_amount rur_amount
              ,t.acc_amount doc_amount
              ,fa.brief doc_fund
              ,t.acc_rate rate
              ,pc.start_date AS p_cover_start_date
              ,pc.end_date AS p_cover_end_date
              ,pc.is_avtoprolongation
              ,pc.fee
              ,pt.number_of_payments
              ,pt.description AS periodicity_name
              ,(SELECT MIN(pa.ag_contract_header_id) AS ag_contract_header_id
                  FROM ins.p_policy_agent_doc pa
                      ,ins.document           dc_pa
                      ,ins.doc_status_ref     dsr_pa
                 WHERE pa.p_policy_agent_doc_id = dc_pa.document_id
                   AND dc_pa.doc_status_ref_id = dsr_pa.doc_status_ref_id
                   AND dsr_pa.brief = 'CURRENT'
                   AND pa.policy_header_id = p.pol_header_id) AS ag_contract_header_id
              ,ph.start_date AS pol_header_start_date
              ,p.end_date AS pol_header_end_date
              ,nvl(t.c_claim_header_id, -1) AS c_claim_header_id
              ,nvl(t.t_damage_code_id, -1) AS t_damage_code_id
              ,pc.p_cover_id
              ,op.document_id
              ,nvl(d.num, 'неопределено') document_num
              ,doc_templ.name document_templ_name
              ,CASE
                 WHEN ph.fund_id <> 122
                      AND fa.brief /*это валюта документа по проводке*/
                      = 'RUR' THEN
                  ROUND(t.acc_amount /
                        decode(ins.acc_new.get_rate_by_id(1, ph.fund_id, t.trans_date)
                              ,0
                              ,1
                              ,ins.acc_new.get_rate_by_id(1, ph.fund_id, t.trans_date)) * 100) / 100
                 ELSE
                  t.acc_amount
               END policy_amount
              , -- сумма в валюте ответственности
               
               CASE
                 WHEN ((dm_tt.brief IN ('СтраховаяПремияОплачена'
                                       , --правило оплаты
                                        'ЗачВзнСтрАг'
                                       ,'ПремияОплаченаПоср'
                                       ,'СтраховаяПремияАвансОпл') AND
                      dso.child_doc_templ_brief IN ('ПП', 'ПП_ОБ', 'ПП_ПС')) OR
                      (dm_tt.brief IN
                      ('СтраховаяПремияАвансОпл', 'УдержКВ') AND
                      dso.child_doc_templ_brief IN ('PAYORDER_SETOFF', 'ЗачетУ_КВ'))) THEN
                  'оплата'
                 WHEN (dm_tt.brief IN ('НачПремия'
                                      , -- проводки по начислению
                                       'МСФОПремияНачAPE'
                                      ,'МСФОПремияНач')) THEN
                  'начисление'
                 ELSE
                  'другое'
               END trans_super_type
              ,t.doc_date trans_doc_date
              ,t.reg_date trans_reg_date
               -- Байтин А.
              ,CASE
                 WHEN ac_dt.brief IN
                      ('ПП', 'ПП_ОБ', 'ПП_ПС', 'PAYORDER_SETOFF', 'ЗачетУ_КВ') THEN
                  ac_dt.brief
               END AS ac_dt_brief
               --374105 Григорьев Ю.А.
              ,trunc(coalesce((SELECT MAX(ap1.due_date)
                                FROM ins.doc_doc     dd
                                    ,ins.doc_set_off dso2
                                    ,ins.ac_payment  ap1
                                    ,ins.doc_set_off dso0
                               WHERE 1 = 1 --dd.parent_id = d.payment_id
                                 AND dd.child_id = dso2.parent_doc_id
                                 AND dso2.child_doc_id = ap1.payment_id
                                 AND d.document_id = dso0.doc_set_off_id
                                 AND dso0.child_doc_id = dd.parent_id)
                             ,(SELECT acp.due_date
                                FROM ins.ac_payment  acp
                                    ,ins.doc_set_off dso2
                               WHERE d.document_id = dso2.doc_set_off_id
                                 AND dso2.child_doc_id = acp.payment_id)
                             ,t.doc_date)
                    ,'dd') trans_doc_date_2
              /**/
                FROM trans_cover            t
                    ,ins.p_cover            pc
                    ,ins.as_asset           a
                    ,ins.as_assured         aa
                    ,ins.p_policy           p
                    ,ins.p_pol_header       ph
                    ,ins.t_prod_line_option plo
                    ,ins.t_product_line     pl
                    ,ins.t_product_ver_lob  pvl
                    ,ins.t_product_version  pv
                    ,ins.t_product          pr
                    ,ins.t_lob_line         ll
                    ,ins.t_insurance_group  ig
                    ,ins.t_payment_terms    pt
                    ,ins.ven_ac_payment     acp
                    ,ins.doc_templ          ac_dt
                     --
                    ,ins.oper op
                    ,ins.document d
                    ,ins.doc_templ doc_templ
                    ,ins_dwh.dm_trans_templ dm_tt
                    ,ins.account dt
                    ,ins.account ct
                    ,(SELECT dso.ent_id
                            ,dso.doc_set_off_id
                            ,dt1.brief child_doc_templ_brief
                            ,dso.child_doc_id
                        FROM ins.ven_doc_set_off dso
                            ,ins.document        d1
                            ,ins.doc_templ       dt1
                       WHERE dso.child_doc_id = d1.document_id
                         AND d1.doc_templ_id = dt1.doc_templ_id) dso
                    ,ins.fund fa
               WHERE pc.as_asset_id = a.as_asset_id
                 AND a.p_policy_id = p.policy_id
                 AND p.pol_header_id = ph.policy_header_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = pl.id
                 AND pl.t_lob_line_id = ll.t_lob_line_id
                 AND ll.insurance_group_id = ig.t_insurance_group_id
                 AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                 AND pv.t_product_version_id = pvl.product_version_id
                 AND pv.product_id = pr.product_id
                 AND p.payment_term_id = pt.id
                 AND a.as_asset_id = aa.as_assured_id
                 AND t.p_cover_id = pc.p_cover_id
                    
                 AND dm_tt.trans_templ_id(+) = t.trans_templ_id
                 AND t.oper_id = op.oper_id
                 AND op.document_id = d.document_id
                 AND d.doc_templ_id = doc_templ.doc_templ_id
                 AND dt.account_id = t.dt_account_id
                 AND ct.account_id = t.ct_account_id
                 AND fa.fund_id(+) = t.acc_fund_id
                    -- Байтин А.
                 AND d.document_id = dso.doc_set_off_id(+)
                    -- Байтин А.
                 AND dso.child_doc_id = acp.payment_id(+)
                 AND acp.doc_templ_id = ac_dt.doc_templ_id(+)) q
            ,ins_dwh.fc_agent fc_a
       WHERE q.date_id = fc_a.date_id(+)
         AND q.ag_contract_header_id = fc_a.ag_contract_header_id(+);
  
    /* Очистка таблицы лога*/
    pra_log_time('proc ' || proc_name || ' => CLEAR MLOG_TRANS');
    DELETE FROM ins_dwh.mlog_trans WHERE seq <= v_seq;
  
    /* Сбор статистики FC_TRANS*/
    pra_log_time('proc ' || proc_name || ' => FC_TRANS GATHER STATS');
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'FC_TRANS', cascade => TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END l_fc_trans;

BEGIN
  NULL;
END;
/

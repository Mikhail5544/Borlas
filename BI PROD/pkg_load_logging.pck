CREATE OR REPLACE PACKAGE pkg_load_logging IS

  -- Author  : Пиядин А.
  -- Created : 10.07.2014
  -- Purpose : 323482 Более 1 ошибки(ТЗ по кредитным договорам)

  FUNCTION get_check_group RETURN NUMBER;

  FUNCTION get_check_single RETURN NUMBER;

  FUNCTION get_process RETURN NUMBER;

  FUNCTION get_process_commit RETURN NUMBER;

  /*
    Пиядин А.
    Функция получения типа ошибки в журнале диагностике
  */
  FUNCTION get_log_row_status_desc(par_load_file_row_log_id load_file_row_log.load_file_row_log_id%TYPE)
    RETURN VARCHAR2;

  /*
    Пиядин А.
    Функция получения стадии загрузки в журнале диагностике
  */
  FUNCTION get_log_load_stage(par_load_file_row_log_id load_file_row_log.load_file_row_log_id%TYPE)
    RETURN VARCHAR2;

  /*
    Пиядин А.
    Функция получения наименования типа проверки по id
  */
  FUNCTION get_check_type_name_by_id(par_t_load_check_type_id t_load_check_type.t_load_check_type_id%TYPE)
    RETURN VARCHAR2;

  /*
    Пиядин А.
    Функция получения текста диагностического сообщения
  */
  FUNCTION get_log_msg(par_load_file_row_log_id load_file_row_log.load_file_row_log_id%TYPE)
    RETURN VARCHAR2;

  /*
    Пиядин А.
    Функция возвращает последний порядковый номер загрузки для файла
  */
  FUNCTION get_max_log_order_num(par_load_file_id load_file.load_file_id%TYPE) RETURN NUMBER;

  /*
    Пиядин А.
    Функция возвращает последнюю запись в журнале диагностики
    в соответствии с приоритетом критичности по загружаемому файлу
  */
  FUNCTION get_max_log_id(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) RETURN NUMBER;

  /*
    Пиядин А.
    Очищает журнал диагностики по ИД записи
  */
  PROCEDURE clear_log_by_row_id(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);

  /*
    Пиядин А.
    Очищает журнал диагностики по ИД записи
  */
  PROCEDURE clear_log_by_file_id(par_load_file_id load_file.load_file_id%TYPE);

  /*
    Пиядин А.
    Формирует запись об ошибке в журнале диагностики
  */
  PROCEDURE add_error
  (
    par_load_file_rows_id    load_file_row_log.load_file_rows_id%TYPE
   ,par_load_order_num       load_file_row_log.load_order_num%TYPE DEFAULT NULL
   ,par_t_load_check_type_id load_file_row_log.t_load_check_type_id%TYPE
   ,par_log_msg              load_file_row_log.log_msg%TYPE
   ,log_row_status           load_file_row_log.log_row_status%TYPE DEFAULT pkg_load_file_to_table.get_error
   ,par_load_stage           load_file_row_log.load_stage%TYPE DEFAULT get_check_single
  );

  /*
    Пиядин А.
    Процедура проставления некритичного статуса для строки
  */
  PROCEDURE set_non_critical_error
  (
    par_load_file_rows_id    load_file_rows.load_file_rows_id%TYPE
   ,par_load_order_num       load_file_row_log.load_order_num%TYPE
   ,par_t_load_check_type_id load_file_row_log.t_load_check_type_id%TYPE
   ,par_log_msg              load_file_row_log.log_msg%TYPE
   ,par_load_stage           load_file_row_log.load_stage%TYPE DEFAULT get_check_single
  );

  /*
    Пиядин А.
    Процедура проставления некритичного статуса для строки
  */
  PROCEDURE set_critical_error
  (
    par_load_file_rows_id    load_file_rows.load_file_rows_id%TYPE
   ,par_load_order_num       load_file_row_log.load_order_num%TYPE
   ,par_t_load_check_type_id load_file_row_log.t_load_check_type_id%TYPE
   ,par_log_msg              load_file_row_log.log_msg%TYPE
   ,par_load_stage           load_file_row_log.load_stage%TYPE DEFAULT get_check_single
  );

END pkg_load_logging;
/
CREATE OR REPLACE PACKAGE BODY pkg_load_logging IS

  -- Журнал диагностики загруженных записей, стадии загрузки
  c_check_group    CONSTANT NUMBER := 1.1; -- Проверка (по совокупности записей)
  c_check_single   CONSTANT NUMBER := 1.2; -- Проверка (по единичной записи)
  c_process        CONSTANT NUMBER := 2.1; -- Обработка
  c_process_commit CONSTANT NUMBER := 2.2; -- Обработка (подтверждение)

  FUNCTION get_check_group RETURN NUMBER IS
  BEGIN
    RETURN c_check_group;
  END get_check_group;

  FUNCTION get_check_single RETURN NUMBER IS
  BEGIN
    RETURN c_check_single;
  END get_check_single;

  FUNCTION get_process RETURN NUMBER IS
  BEGIN
    RETURN c_process;
  END get_process;

  FUNCTION get_process_commit RETURN NUMBER IS
  BEGIN
    RETURN c_process_commit;
  END get_process_commit;

  /*
    Пиядин А.
    Функция получения типа ошибки в журнале диагностике
  */
  FUNCTION get_log_row_status_desc(par_load_file_row_log_id load_file_row_log.load_file_row_log_id%TYPE)
    RETURN VARCHAR2 IS
    v_result VARCHAR2(500);
  BEGIN
    SELECT CASE frl.log_row_status
             WHEN pkg_load_file_to_table.get_error THEN
              'Ошибка'
             WHEN pkg_load_file_to_table.get_nc_error THEN
              'Некритичная ошибка'
           END res
      INTO v_result
      FROM load_file_row_log frl
     WHERE 1 = 1
       AND frl.load_file_row_log_id = par_load_file_row_log_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_log_row_status_desc;

  /*
    Пиядин А.
    Функция получения стадии загрузки в журнале диагностике
  */
  FUNCTION get_log_load_stage(par_load_file_row_log_id load_file_row_log.load_file_row_log_id%TYPE)
    RETURN VARCHAR2 IS
    v_result VARCHAR2(500);
  BEGIN
    SELECT CASE frl.load_stage
             WHEN c_check_group THEN
              'Проверка (по совокупности записей)'
             WHEN c_check_single THEN
              'Проверка (по единичной записи)'
             WHEN c_process THEN
              'Обработка'
             WHEN c_process_commit THEN
              'Обработка (подтверждение)'
           END res
      INTO v_result
      FROM load_file_row_log frl
     WHERE 1 = 1
       AND frl.load_file_row_log_id = par_load_file_row_log_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_log_load_stage;

  /*
    Пиядин А.
    Функция получения наименования типа проверки по id
  */
  FUNCTION get_check_type_name_by_id(par_t_load_check_type_id t_load_check_type.t_load_check_type_id%TYPE)
    RETURN VARCHAR2 IS
    v_check_type dml_t_load_check_type.tt_t_load_check_type;
  BEGIN
    v_check_type := dml_t_load_check_type.get_record(par_t_load_check_type_id);
  
    RETURN v_check_type.description;
  END get_check_type_name_by_id;

  /*
    Пиядин А.
    Функция получения текста диагностического сообщения
  */
  FUNCTION get_log_msg(par_load_file_row_log_id load_file_row_log.load_file_row_log_id%TYPE)
    RETURN VARCHAR2 IS
    v_result load_file_row_log.log_msg%TYPE;
  BEGIN
    SELECT frl.log_msg
      INTO v_result
      FROM load_file_row_log frl
     WHERE 1 = 1
       AND frl.load_file_row_log_id = par_load_file_row_log_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_log_msg;

  /*
    Пиядин А.
    Функция возвращает последний порядковый номер загрузки для файла
  */
  FUNCTION get_max_log_order_num(par_load_file_id load_file.load_file_id%TYPE) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(MAX(frl.load_order_num), 0)
      INTO v_result
      FROM load_file_row_log frl
     WHERE frl.load_file_id = par_load_file_id;
  
    RETURN v_result;
  END get_max_log_order_num;

  /*
    Пиядин А.
    Функция возвращает последнюю запись в журнале диагностики
    в соответствии с приоритетом критичности по строке
  */
  FUNCTION get_max_log_id(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT max_id
      INTO v_result
      FROM (SELECT MAX(frl.load_file_row_log_id) max_id
              FROM load_file_row_log frl
             WHERE frl.load_file_rows_id = par_load_file_rows_id
               AND frl.load_order_num = get_max_log_order_num(frl.load_file_id)
             GROUP BY frl.log_row_status
             ORDER BY frl.log_row_status DESC)
     WHERE rownum = 1;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        SELECT MAX(frl.load_file_row_log_id)
          INTO v_result
          FROM load_file_row_log frl
         WHERE frl.load_file_rows_id = par_load_file_rows_id;
      
        RETURN v_result;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END;
  END get_max_log_id;

  /*
    Пиядин А.
    Очищает журнал диагностики по ИД записи
  */
  PROCEDURE clear_log_by_row_id(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    DELETE FROM load_file_row_log frl WHERE frl.load_file_rows_id = par_load_file_rows_id;
  END clear_log_by_row_id;

  /*
    Пиядин А.
    Очищает журнал диагностики по ИД записи
  */
  PROCEDURE clear_log_by_file_id(par_load_file_id load_file.load_file_id%TYPE) IS
  BEGIN
    DELETE FROM load_file_row_log frl
     WHERE frl.load_file_rows_id IN
           (SELECT fr.load_file_rows_id FROM load_file_rows fr WHERE fr.load_file_id = par_load_file_id);
  END clear_log_by_file_id;

  /*
    Пиядин А.
    Формирует запись об ошибке в журнале диагностики
  */
  PROCEDURE add_error
  (
    par_load_file_rows_id    load_file_row_log.load_file_rows_id%TYPE
   ,par_load_order_num       load_file_row_log.load_order_num%TYPE DEFAULT NULL
   ,par_t_load_check_type_id load_file_row_log.t_load_check_type_id%TYPE
   ,par_log_msg              load_file_row_log.log_msg%TYPE
   ,log_row_status           load_file_row_log.log_row_status%TYPE DEFAULT pkg_load_file_to_table.get_error
   ,par_load_stage           load_file_row_log.load_stage%TYPE DEFAULT get_check_single
  ) IS
    v_load_order_num    load_file_row_log.load_order_num%TYPE;
    v_exists            NUMBER;
    v_load_file_rows    dml_load_file_rows.tt_load_file_rows;
    v_load_file_row_log dml_load_file_row_log.tt_load_file_row_log;
    v_load_file_id      ins.load_file_rows.load_file_id%TYPE;
  BEGIN
  
    IF par_load_order_num IS NULL
    THEN
      v_load_file_rows := dml_load_file_rows.get_record(par_load_file_rows_id);
    END IF;
    v_load_order_num := coalesce(par_load_order_num
                                ,get_max_log_order_num(v_load_file_rows.load_file_id) + 1);
  
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM load_file_row_log frl
             WHERE 1 = 1
               AND frl.load_order_num = v_load_order_num
               AND frl.t_load_check_type_id = par_t_load_check_type_id
               AND frl.log_msg = par_log_msg
               AND frl.log_row_status = log_row_status
               AND frl.load_stage = par_load_stage
               AND frl.load_file_rows_id = par_load_file_rows_id);
  
    IF v_exists = 0
    THEN
      SELECT lfr.load_file_id
        INTO v_load_file_id
        FROM ins.load_file_rows lfr
       WHERE lfr.load_file_rows_id = par_load_file_rows_id;
    
      v_load_file_row_log.load_file_rows_id    := par_load_file_rows_id;
      v_load_file_row_log.load_order_num       := v_load_order_num;
      v_load_file_row_log.t_load_check_type_id := par_t_load_check_type_id;
      v_load_file_row_log.log_msg              := par_log_msg;
      v_load_file_row_log.log_row_status       := log_row_status;
      v_load_file_row_log.load_stage           := par_load_stage;
      v_load_file_row_log.load_file_id         := v_load_file_id;
    
      dml_load_file_row_log.insert_record(v_load_file_row_log);
    END IF;
  END add_error;

  /*
    Пиядин А.
    Процедура проставления некритичного статуса для строки
  */
  PROCEDURE set_non_critical_error
  (
    par_load_file_rows_id    load_file_rows.load_file_rows_id%TYPE
   ,par_load_order_num       load_file_row_log.load_order_num%TYPE
   ,par_t_load_check_type_id load_file_row_log.t_load_check_type_id%TYPE
   ,par_log_msg              load_file_row_log.log_msg%TYPE
   ,par_load_stage           load_file_row_log.load_stage%TYPE DEFAULT get_check_single
  ) IS
  BEGIN
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_nc_error);
  
    add_error(par_load_file_rows_id    => par_load_file_rows_id
             ,par_load_order_num       => par_load_order_num
             ,par_t_load_check_type_id => par_t_load_check_type_id
             ,par_log_msg              => par_log_msg
             ,log_row_status           => pkg_load_file_to_table.get_nc_error
             ,par_load_stage           => par_load_stage);
  END set_non_critical_error;

  /*
    Пиядин А.
    Процедура проставления некритичного статуса для строки
  */
  PROCEDURE set_critical_error
  (
    par_load_file_rows_id    load_file_rows.load_file_rows_id%TYPE
   ,par_load_order_num       load_file_row_log.load_order_num%TYPE
   ,par_t_load_check_type_id load_file_row_log.t_load_check_type_id%TYPE
   ,par_log_msg              load_file_row_log.log_msg%TYPE
   ,par_load_stage           load_file_row_log.load_stage%TYPE DEFAULT get_check_single
  ) IS
  BEGIN
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_error);
  
    add_error(par_load_file_rows_id    => par_load_file_rows_id
             ,par_load_order_num       => par_load_order_num
             ,par_t_load_check_type_id => par_t_load_check_type_id
             ,par_log_msg              => par_log_msg
             ,log_row_status           => pkg_load_file_to_table.get_error
             ,par_load_stage           => par_load_stage);
  END set_critical_error;

END pkg_load_logging;
/

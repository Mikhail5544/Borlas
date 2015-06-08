CREATE OR REPLACE PACKAGE PKG_CONVERT AS
  /**
  * Пакет предназначен для конвертации данных из шлюзовой области в
  * базу данных Borlas Insurens.
  * <p>
  * Пакет включает в себя частичную
  * проверку данных на целосность.
  *
  * @author Sheshko Andrei
  * @author Surovtsev Alexey
  * @version 1.0
  * @headcom
  */

  /**
  * Логические константы пакета
  * <ul>
  *  <li> лож
  *  <li> истина
  *  <li> исключение
  * </ul>
  */
  c_true  CONSTANT NUMBER := 1;
  c_false CONSTANT NUMBER := 0;
  c_exept CONSTANT NUMBER := -1;

  is_debug CONSTANT NUMBER := c_true;

  /**
  * Данное исключение генерируется логическими функциями {@link PKG_CONVERT.Raise_ExB} и {@link PKG_CONVERT.Raise_Ex}
  */
  res_exception EXCEPTION;

  /**
  * Не используется в данной версии
  */
  res_value_exc NUMBER;

  /**
  * Константы типов сообщений записывающихся в таблицу логирования конвертации.
  * <ul>
  * <li> log_error - сообщение сообщающее об ошибке
  * <li> log_info -  простое информационное сообщение
  * </ul>
  * @see PKG_CONVERT.SP_Event
  * @see PKG_CONVERT.SP_EventError
  * @see PKG_CONVERT.SP_EventInfo
  */
  log_error CONSTANT NUMBER := -1;
  log_info  CONSTANT NUMBER := 0;

  /**
  * Логическая процедура. Реализует двух-значную логику.
  * <p>
  * Функция генерирует исключение  {@link PKG_CONVERT.res_exception} если выполняется условие p_val = p_val_1.
  * @param p_val первый логические параметр
  * @param p_val_1 второй логические параметр
  * @see PKG_CONVERT.res_exception
  */
  PROCEDURE Raise_ExB
  (
    p_val   BOOLEAN
   ,p_val_1 BOOLEAN
  );

  /**
  * Логическая фунция. Реализует трех-значную логику.
  * <p>
  * Процедура генерирует исключение  {@link PKG_CONVERT.res_exception} если выполняется условия:
  * <ul>
  * <li> (p_val = p_val_2)
  * <li> (p_val <> p_val_2) and (p_val_1 is not null) and (p_val = p_val_1)
  * </ul>
  * Процедура не генерирует исключение  если выполняется условия:
  * <ul>
  * <li> (p_val <> p_val_2) and (p_val_1 is null)
  * <li> (p_val <> p_val_2) and (p_val_1 is not null) and (p_val <> p_val_1)
  * </ul>
  * @param p_val   первый параметр
  * @param p_val_1 второй параметр
  * @param p_val_2 третий параметр
  * @see PKG_CONVERT.res_exception
  */
  PROCEDURE Raise_Ex
  (
    p_val   NUMBER
   ,p_val_1 NUMBER := NULL
   ,p_val_2 NUMBER := c_exept
  );

  /**
  * Генерирует сообщее в DBMS_OUTPUT
  * @param p_mess сообщение
  */
  PROCEDURE SP_PUTLINE(p_mess VARCHAR2);

  /**
  * Процедура запуска процесса конвертации.
  * <p>
  * Процедура запускает по порядку функции из пакета {@link PKG_CONVERT_BLogic}. Порядок и параметры запуска функций записываются в таблице CONVERT_PROCESS. <br>
  * Если во время работы пакета и процедур возникают ошибки, все результаты записываются в таблицу логирования CONVERT_LOG.
  */
  PROCEDURE SP_PROCESS_RUN;

  /**
  * Процедура запуска процесса проверки данных в шлюзовых таблицах.
  * <p>
  * Процедура запускает по порядку функции из пакета {@link PKG_CONVERT_BLogic}. Порядок и параметры запуска функций записываются в таблице CONVERT_PROCESS. <br>
  * Результаты проверки данных записываются в таблицу логирования CONVERT_LOG.
  */
  PROCEDURE SP_PROCESS_VALID;

  /**
  * Процедура записи сообщения в таблицу CONVERT_LOG.
  * <p>
  * @param p_err_mess текст сообщения. Например "Ошибка при конвертации объекта ХХХ"
  * @param p_name_pkg наименование пакета, где произошла ошибка.
  * @param p_name_fn  наименование функции, где произошла ошибка.
  * @param p_sql_err_num код ошибки. Например sqlcode.
  * @param p_sql_err_msg текст ошибки. Например sqlerrm.
  * @param p_type  тип сообщения. Может принимать одно из двух значений {@link PKG_CONVERT.log_error} или {@link PKG_CONVERT.log_info}.
  * @see  PKG_CONVERT.log_error
  * @see  PKG_CONVERT.log_info
  * @see  PKG_CONVERT.SP_EventError
  * @see  PKG_CONVERT.SP_EventInfo
  */
  PROCEDURE SP_Event
  (
    p_err_mess    VARCHAR2
   ,p_name_pkg    VARCHAR2 := NULL
   ,p_name_fn     VARCHAR2 := NULL
   ,p_sql_err_num NUMBER := NULL
   ,p_sql_err_msg VARCHAR2 := NULL
   ,p_type        NUMBER
  );

  /**
  * Процедура записи сообщения об ошибке в таблицу CONVERT_LOG.
  * <p>
  * @param p_err_mess текст сообщения. Например "Ошибка при конвертации объекта ХХХ"
  * @param p_name_pkg наименование пакета, где произошла ошибка.
  * @param p_name_fn  наименование функции, где произошла ошибка.
  * @param p_sql_err_num код ошибки. Например sqlcode.
  * @param p_sql_err_msg текст ошибки. Например sqlerrm.
  * @see  PKG_CONVERT.log_error
  * @see  PKG_CONVERT.log_info
  * @see  PKG_CONVERT.SP_Event
  * @see  PKG_CONVERT.SP_EventInfo
  */
  PROCEDURE SP_EventError
  (
    p_err_mess    VARCHAR2
   ,p_name_pkg    VARCHAR2 := NULL
   ,p_name_fn     VARCHAR2 := NULL
   ,p_sql_err_num NUMBER := NULL
   ,p_sql_err_msg VARCHAR2 := NULL
  );

  /**
  * Процедура записи сообщения в таблицу CONVERT_LOG.
  * <p>
  * @param p_err_mess текст сообщения. Например "Конвертация объекта ХХХ"
  * @param p_name_pkg наименование пакета.
  * @param p_name_fn  наименование функции.
  * @see  PKG_CONVERT.log_error
  * @see  PKG_CONVERT.log_info
  * @see  PKG_CONVERT.SP_Event
  * @see  PKG_CONVERT.SP_EventError
  */
  PROCEDURE SP_EventInfo
  (
    p_err_mess VARCHAR2
   ,p_name_pkg VARCHAR2 := NULL
   ,p_name_fn  VARCHAR2 := NULL
  );

  /**
  * Процедура изменяющее состояние любого поля в любой таблице с 0 на 1.
  * <p>
  * @param p_name_table таблица. Например CONVERT_CONTACT.
  * @param x rowid строки которую надо изменить.
  * @param p_col_name cтолбец значение которого надо изменить. По умолчанию is_convert
  */
  PROCEDURE UpdateConvert
  (
    p_name_table VARCHAR2
   ,x            ROWID
   ,p_col_name   VARCHAR2 := 'is_convert'
  );

  /**
  * Процедура изменяющее состояние любого поля в любой таблице с 1 на 0.
  * <p>
  * @param p_name_table таблица. Например CONVERT_CONTACT.
  * @param x rowid строки которую надо изменить.
  * @param p_col_name cтолбец значение которого надо изменить. По умолчанию is_convert
  */
  PROCEDURE UnCheckConvert
  (
    p_name_table VARCHAR2
   ,x            ROWID
   ,p_col_name   VARCHAR2 := 'is_convert'
  );
END PKG_CONVERT;
/
CREATE OR REPLACE PACKAGE BODY PKG_CONVERT AS
  /**
  * Загрузка данных по контрагентам,
  *      банкам и договарам
  *
  * @author Sheshko Andrei
  * @version 1.0
  */

  PROCEDURE Raise_ExB
  (
    p_val   BOOLEAN
   ,p_val_1 BOOLEAN
  ) IS
  BEGIN
    IF (p_val = p_val_1)
    THEN
      RAISE res_exception;
    END IF;
  
  END Raise_ExB;

  PROCEDURE Raise_Ex
  (
    p_val   NUMBER
   ,p_val_1 NUMBER := NULL
   ,p_val_2 NUMBER := c_exept
  ) IS
  BEGIN
    res_value_exc := p_val;
  
    IF (p_val = p_val_2)
    THEN
      RAISE res_exception;
    END IF;
  
    IF (p_val_1 IS NULL)
    THEN
      RETURN;
    END IF;
  
    IF (p_val = p_val_1)
    THEN
      RAISE res_exception;
    END IF;
  END Raise_Ex;

  PROCEDURE SP_PROCESS_VALID IS
    CURSOR cur_proc IS
      SELECT * FROM convert_process pr WHERE pr.STATUS = 0 ORDER BY pr.NUM_PROCESS;
  
    rec_proc cur_proc%ROWTYPE;
  BEGIN
    FOR rec_proc IN cur_proc
    LOOP
      EXECUTE IMMEDIATE 'BEGIN ' || rec_proc.FN_VALID || '; END;';
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      SP_EventError('ошибка при работе проверке данных'
                   ,'PKG_CONVERT'
                   ,'SP_PROCESS_VALID'
                   ,SQLCODE
                   ,SQLERRM);
  END SP_PROCESS_VALID;

  PROCEDURE SP_PROCESS_RUN IS
    CURSOR cur_proc IS
      SELECT * FROM convert_process pr WHERE pr.STATUS = 0 ORDER BY pr.NUM_PROCESS;
    name_proc VARCHAR2(255);
    lres      NUMBER;
  BEGIN
    SP_PUTLINE('process_run start');
    FOR rec_proc IN cur_proc
    LOOP
      SP_PUTLINE('process_run begin ->' || rec_proc.proc_name);
      PKG_CONVERT.SP_EventInfo('PKG_CONVERT', 'SP_PROCESS_RUN', 'Запуск:' || rec_proc.proc_name);
    
      EXECUTE IMMEDIATE 'BEGIN :val1:=' || rec_proc.proc_name || '(:val2); END;'
        USING OUT lres, IN rec_proc.CHECK_DUPLICATE;
    
      SP_PUTLINE('process_run start return ' || lres);
    
      IF (lres <> c_true)
      THEN
        ROLLBACK;
        PKG_CONVERT.SP_EventInfo('PKG_CONVERT'
                                ,'SP_PROCESS_RUN'
                                ,'Аварийное завершение:' || rec_proc.proc_name);
        RETURN;
      ELSE
        COMMIT;
        PKG_CONVERT.SP_EventInfo('PKG_CONVERT'
                                ,'SP_PROCESS_RUN'
                                ,'Успешное завершение:' || rec_proc.proc_name);
      END IF;
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      SP_EventError('ошибка при работе конвертации'
                   ,'PKG_CONVERT'
                   ,'SP_PROCESS_RUN'
                   ,SQLCODE
                   ,SQLERRM);
      ROLLBACK;
  END SP_PROCESS_RUN;

  /* процедуда записи логов ошибок  */
  PROCEDURE SP_InserEvent
  (
    p_err_mess VARCHAR2
   ,p_type     NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO INS.CONVERT_LOG
      (CONVERT_EVENT_ID, MESSAGE_EVENT, CONVERT_EVENT_TYPE_ID, MESSAGE_DATE)
    VALUES
      (INS.SQ_CONVERT_LOG.NEXTVAL, p_err_mess, p_type, SYSDATE);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      ROLLBACK;
  END SP_InserEvent;

  PROCEDURE SP_Event
  (
    p_err_mess    VARCHAR2
   ,p_name_pkg    VARCHAR2 := NULL
   ,p_name_fn     VARCHAR2 := NULL
   ,p_sql_err_num NUMBER := NULL
   ,p_sql_err_msg VARCHAR2 := NULL
   ,p_type        NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO INS.CONVERT_LOG
      (CONVERT_EVENT_ID
      ,MESSAGE_EVENT
      ,CONVERT_EVENT_TYPE_ID
      ,MESSAGE_DATE
      ,name_pkg
      ,name_fn
      ,sql_err_num
      ,sql_err_msg)
    VALUES
      (INS.SQ_CONVERT_LOG.NEXTVAL
      ,p_err_mess
      ,p_type
      ,SYSDATE
      ,UPPER(p_name_pkg)
      ,UPPER(p_name_fn)
      ,p_sql_err_num
      ,p_sql_err_msg);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      ROLLBACK;
  END SP_Event;

  PROCEDURE SP_EventError
  (
    p_err_mess    VARCHAR2
   ,p_name_pkg    VARCHAR2 := NULL
   ,p_name_fn     VARCHAR2 := NULL
   ,p_sql_err_num NUMBER := NULL
   ,p_sql_err_msg VARCHAR2 := NULL
  ) IS
  BEGIN
    SP_Event(p_err_mess, p_name_pkg, p_name_fn, p_sql_err_num, p_sql_err_msg, log_error);
  END SP_EventError;

  PROCEDURE SP_EventInfo
  (
    p_err_mess VARCHAR2
   ,p_name_pkg VARCHAR2 := NULL
   ,p_name_fn  VARCHAR2 := NULL
  ) IS
  BEGIN
    SP_Event(p_err_mess, p_name_pkg => p_name_pkg, p_name_fn => p_name_fn, p_type => log_info);
  END SP_EventInfo;

  PROCEDURE SP_PUTLINE(p_mess VARCHAR2) IS
  BEGIN
    IF (is_debug = c_true)
    THEN
      dbms_output.put_line(p_mess);
    END IF;
  END SP_PUTLINE;

  PROCEDURE UpdateConvert
  (
    p_name_table VARCHAR2
   ,x            ROWID
   ,p_col_name   VARCHAR2 := 'is_convert'
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /*
    EXECUTE IMMEDIATE
    'update '||p_name_table||' set '||p_col_name||'=1 where rowid=:val'
    USING in x ;*/
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      SP_EventError('ошибка при маркировании строки'
                   ,'PKG_CONVERT'
                   ,'UpdateConvert'
                   ,SQLCODE
                   ,SQLERRM);
      ROLLBACK;
  END UpdateConvert;

  PROCEDURE UnCheckConvert
  (
    p_name_table VARCHAR2
   ,x            ROWID
   ,p_col_name   VARCHAR2 := 'is_convert'
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE 'update ' || p_name_table || ' set ' || p_col_name || '=2 where rowid=:val'
      USING IN x;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      SP_EventError('ошибка при маркировании строки'
                   ,'PKG_CONVERT'
                   ,'UpdateConvert'
                   ,SQLCODE
                   ,SQLERRM);
      ROLLBACK;
  END UnCheckConvert;

END PKG_CONVERT;
/

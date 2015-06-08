CREATE OR REPLACE PACKAGE PKG_INS_LOG AS
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
   ,p_type        VARCHAR2
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

END PKG_INS_LOG;
/
CREATE OR REPLACE PACKAGE BODY PKG_INS_LOG AS
  /**
  * Загрузка данных по контрагентам,
  *      банкам и договарам
  *
  * @author Sheshko Andrei
  * @version 1.0
  */

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
    INSERT INTO CONVERT_LOG
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

END PKG_INS_LOG;
/

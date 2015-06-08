CREATE OR REPLACE PACKAGE PKG_CONVERT AS
  /**
  * ����� ������������ ��� ����������� ������ �� �������� ������� �
  * ���� ������ Borlas Insurens.
  * <p>
  * ����� �������� � ���� ���������
  * �������� ������ �� ����������.
  *
  * @author Sheshko Andrei
  * @author Surovtsev Alexey
  * @version 1.0
  * @headcom
  */

  /**
  * ���������� ��������� ������
  * <ul>
  *  <li> ���
  *  <li> ������
  *  <li> ����������
  * </ul>
  */
  c_true  CONSTANT NUMBER := 1;
  c_false CONSTANT NUMBER := 0;
  c_exept CONSTANT NUMBER := -1;

  is_debug CONSTANT NUMBER := c_true;

  /**
  * ������ ���������� ������������ ����������� ��������� {@link PKG_CONVERT.Raise_ExB} � {@link PKG_CONVERT.Raise_Ex}
  */
  res_exception EXCEPTION;

  /**
  * �� ������������ � ������ ������
  */
  res_value_exc NUMBER;

  /**
  * ��������� ����� ��������� �������������� � ������� ����������� �����������.
  * <ul>
  * <li> log_error - ��������� ���������� �� ������
  * <li> log_info -  ������� �������������� ���������
  * </ul>
  * @see PKG_CONVERT.SP_Event
  * @see PKG_CONVERT.SP_EventError
  * @see PKG_CONVERT.SP_EventInfo
  */
  log_error CONSTANT NUMBER := -1;
  log_info  CONSTANT NUMBER := 0;

  /**
  * ���������� ���������. ��������� ����-������� ������.
  * <p>
  * ������� ���������� ����������  {@link PKG_CONVERT.res_exception} ���� ����������� ������� p_val = p_val_1.
  * @param p_val ������ ���������� ��������
  * @param p_val_1 ������ ���������� ��������
  * @see PKG_CONVERT.res_exception
  */
  PROCEDURE Raise_ExB
  (
    p_val   BOOLEAN
   ,p_val_1 BOOLEAN
  );

  /**
  * ���������� ������. ��������� ����-������� ������.
  * <p>
  * ��������� ���������� ����������  {@link PKG_CONVERT.res_exception} ���� ����������� �������:
  * <ul>
  * <li> (p_val = p_val_2)
  * <li> (p_val <> p_val_2) and (p_val_1 is not null) and (p_val = p_val_1)
  * </ul>
  * ��������� �� ���������� ����������  ���� ����������� �������:
  * <ul>
  * <li> (p_val <> p_val_2) and (p_val_1 is null)
  * <li> (p_val <> p_val_2) and (p_val_1 is not null) and (p_val <> p_val_1)
  * </ul>
  * @param p_val   ������ ��������
  * @param p_val_1 ������ ��������
  * @param p_val_2 ������ ��������
  * @see PKG_CONVERT.res_exception
  */
  PROCEDURE Raise_Ex
  (
    p_val   NUMBER
   ,p_val_1 NUMBER := NULL
   ,p_val_2 NUMBER := c_exept
  );

  /**
  * ���������� ������� � DBMS_OUTPUT
  * @param p_mess ���������
  */
  PROCEDURE SP_PUTLINE(p_mess VARCHAR2);

  /**
  * ��������� ������� �������� �����������.
  * <p>
  * ��������� ��������� �� ������� ������� �� ������ {@link PKG_CONVERT_BLogic}. ������� � ��������� ������� ������� ������������ � ������� CONVERT_PROCESS. <br>
  * ���� �� ����� ������ ������ � �������� ��������� ������, ��� ���������� ������������ � ������� ����������� CONVERT_LOG.
  */
  PROCEDURE SP_PROCESS_RUN;

  /**
  * ��������� ������� �������� �������� ������ � �������� ��������.
  * <p>
  * ��������� ��������� �� ������� ������� �� ������ {@link PKG_CONVERT_BLogic}. ������� � ��������� ������� ������� ������������ � ������� CONVERT_PROCESS. <br>
  * ���������� �������� ������ ������������ � ������� ����������� CONVERT_LOG.
  */
  PROCEDURE SP_PROCESS_VALID;

  /**
  * ��������� ������ ��������� � ������� CONVERT_LOG.
  * <p>
  * @param p_err_mess ����� ���������. �������� "������ ��� ����������� ������� ���"
  * @param p_name_pkg ������������ ������, ��� ��������� ������.
  * @param p_name_fn  ������������ �������, ��� ��������� ������.
  * @param p_sql_err_num ��� ������. �������� sqlcode.
  * @param p_sql_err_msg ����� ������. �������� sqlerrm.
  * @param p_type  ��� ���������. ����� ��������� ���� �� ���� �������� {@link PKG_CONVERT.log_error} ��� {@link PKG_CONVERT.log_info}.
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
  * ��������� ������ ��������� �� ������ � ������� CONVERT_LOG.
  * <p>
  * @param p_err_mess ����� ���������. �������� "������ ��� ����������� ������� ���"
  * @param p_name_pkg ������������ ������, ��� ��������� ������.
  * @param p_name_fn  ������������ �������, ��� ��������� ������.
  * @param p_sql_err_num ��� ������. �������� sqlcode.
  * @param p_sql_err_msg ����� ������. �������� sqlerrm.
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
  * ��������� ������ ��������� � ������� CONVERT_LOG.
  * <p>
  * @param p_err_mess ����� ���������. �������� "����������� ������� ���"
  * @param p_name_pkg ������������ ������.
  * @param p_name_fn  ������������ �������.
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
  * ��������� ���������� ��������� ������ ���� � ����� ������� � 0 �� 1.
  * <p>
  * @param p_name_table �������. �������� CONVERT_CONTACT.
  * @param x rowid ������ ������� ���� ��������.
  * @param p_col_name c������ �������� �������� ���� ��������. �� ��������� is_convert
  */
  PROCEDURE UpdateConvert
  (
    p_name_table VARCHAR2
   ,x            ROWID
   ,p_col_name   VARCHAR2 := 'is_convert'
  );

  /**
  * ��������� ���������� ��������� ������ ���� � ����� ������� � 1 �� 0.
  * <p>
  * @param p_name_table �������. �������� CONVERT_CONTACT.
  * @param x rowid ������ ������� ���� ��������.
  * @param p_col_name c������ �������� �������� ���� ��������. �� ��������� is_convert
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
  * �������� ������ �� ������������,
  *      ������ � ���������
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
      SP_EventError('������ ��� ������ �������� ������'
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
      PKG_CONVERT.SP_EventInfo('PKG_CONVERT', 'SP_PROCESS_RUN', '������:' || rec_proc.proc_name);
    
      EXECUTE IMMEDIATE 'BEGIN :val1:=' || rec_proc.proc_name || '(:val2); END;'
        USING OUT lres, IN rec_proc.CHECK_DUPLICATE;
    
      SP_PUTLINE('process_run start return ' || lres);
    
      IF (lres <> c_true)
      THEN
        ROLLBACK;
        PKG_CONVERT.SP_EventInfo('PKG_CONVERT'
                                ,'SP_PROCESS_RUN'
                                ,'��������� ����������:' || rec_proc.proc_name);
        RETURN;
      ELSE
        COMMIT;
        PKG_CONVERT.SP_EventInfo('PKG_CONVERT'
                                ,'SP_PROCESS_RUN'
                                ,'�������� ����������:' || rec_proc.proc_name);
      END IF;
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      SP_EventError('������ ��� ������ �����������'
                   ,'PKG_CONVERT'
                   ,'SP_PROCESS_RUN'
                   ,SQLCODE
                   ,SQLERRM);
      ROLLBACK;
  END SP_PROCESS_RUN;

  /* ��������� ������ ����� ������  */
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
      SP_EventError('������ ��� ������������ ������'
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
      SP_EventError('������ ��� ������������ ������'
                   ,'PKG_CONVERT'
                   ,'UpdateConvert'
                   ,SQLCODE
                   ,SQLERRM);
      ROLLBACK;
  END UnCheckConvert;

END PKG_CONVERT;
/

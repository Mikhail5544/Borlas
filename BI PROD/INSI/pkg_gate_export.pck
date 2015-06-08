CREATE OR REPLACE PACKAGE PKG_GATE_EXPORT IS
  PROCEDURE Job;
  PROCEDURE JobImport;

  FUNCTION GetStrColumn(tab_name VARCHAR2) RETURN VARCHAR2;
END PKG_GATE_EXPORT;
/
CREATE OR REPLACE PACKAGE BODY PKG_GATE_EXPORT IS

  FUNCTION Export
  (
    p_execute_sql IN VARCHAR2
   ,p_num_package IN NUMBER
   ,p_in          BOOLEAN := FALSE
  ) RETURN NUMBER IS
    sql_str VARCHAR2(3000);
    sql_col VARCHAR2(1000);
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  
    sql_col := GetStrColumn(p_execute_sql);
  
    IF (p_in)
    THEN
      sql_str := 'insert into ' || p_execute_sql || ' (' || sql_col || ')' || ' select ' || sql_col ||
                 ' from ' || p_execute_sql || '@GATEBI ' || ' where GATE_PACKAGE_ID = ' ||
                 p_num_package;
    ELSE
      sql_str := 'insert into ' || p_execute_sql || '@GATEBI (' || sql_col || ')' || ' select ' ||
                 sql_col || ' from ' || p_execute_sql || ' where GATE_PACKAGE_ID = ' || p_num_package;
    END IF;
  
    pkg_gate.EventRet := pkg_gate.InserEvent(sql_str, pkg_gate.event_error);
    EXECUTE IMMEDIATE sql_str;
    /*    insert into GATE_AC_PAY_IN ( CODE,AC_NUM,BI_AC_PAYMENT_ID,AC_PAYMENT_DATE,ROW_STATUS,GATE_PACKAGE_ID) values(1,1,1,SYSDATE,1,1);
    --select  CODE,AC_NUM,BI_AC_PAYMENT_ID,AC_PAYMENT_DATE,ROW_STATUS,GATE_PACKAGE_ID from GATE_AC_PAY_IN@GATEBI  where GATE_PACKAGE_ID = 1;*/
  
    COMMIT;
    pkg_gate.EventRet := pkg_gate.InserEvent('2', pkg_gate.event_error);
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Export(текст запроса) : ' || sql_str
                                              ,pkg_gate.event_error);
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Export: ' || SQLERRM
                                              ,pkg_gate.event_error);
      ROLLBACK;
      RETURN Utils.c_false;
  END Export;

  PROCEDURE Job IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    res NUMBER := Utils.c_false;
    p_d DATE := SYSDATE;
  
    CURSOR gate_ex(p_type IN NUMBER) IS
      SELECT * FROM GATE_OBJ_EXPORT_LINE WHERE GATE_OBJ_TYPE_ID = p_type ORDER BY NUM_EXE ASC;
  
    exp_syn_err     EXCEPTION;
    exp_pack_err    EXCEPTION;
    exp_export_err  EXCEPTION;
    exp_finish_err  EXCEPTION;
    exp_mssql_err   EXCEPTION;
    exp_delpack_err EXCEPTION;
    exp_status_err  EXCEPTION;
  
  BEGIN
  
    res := pkg_gate.SynchronizeGate;
  
    IF (res = Utils.c_false)
    THEN
      RAISE exp_syn_err;
    END IF;
  
    FOR rec IN (SELECT * FROM GATE_MESSAGE ORDER BY GATE_MESSAGE_ID ASC)
    LOOP
    
      res := pkg_gate.ExportPackage(rec.PACK_ID);
      IF (res != Utils.c_true)
      THEN
        RAISE exp_pack_err;
      END IF;
    
      FOR rec_ex IN gate_ex(rec.MESS_TYPE)
      LOOP
        res := Export(rec_ex.EXPORT_LINE, rec.PACK_ID);
        IF (res = Utils.c_false)
        THEN
          RAISE exp_export_err;
        END IF;
      END LOOP;
    
      res := pkg_gate.Finishing(rec.MESS_TYPE, rec.PACK_ID);
    
      IF (res = Utils.c_false)
      THEN
        RAISE exp_finish_err;
      END IF;
    
      res := pkg_gate.SetPackageStatusMSSQL(rec.PACK_ID, pkg_gate.pkg_state_loading);
    
      IF (res = Utils.c_false)
      THEN
        RAISE exp_mssql_err;
      END IF;
    
      res := pkg_gate.DeleteMessage_Gate(rec.GATE_MESSAGE_ID);
      IF (res = Utils.c_false)
      THEN
        RAISE exp_delpack_err;
      END IF;
    
      res := pkg_gate.SetStatusProcessComplite(rec.MESS_TYPE);
      IF (res = Utils.c_false)
      THEN
        RAISE exp_status_err;
      END IF;
    
      COMMIT;
    END LOOP;
  
  EXCEPTION
    WHEN exp_syn_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при синхронизации типов'
                                              ,pkg_gate.event_error);
    WHEN exp_status_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при назаначеии статуса пакета'
                                              ,pkg_gate.event_error);
    WHEN exp_delpack_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при удалении пакета '
                                              ,pkg_gate.event_error);
    WHEN exp_mssql_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при обращении к пакету в MSSQL '
                                              ,pkg_gate.event_error);
    WHEN exp_finish_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при сохранении истории '
                                              ,pkg_gate.event_error);
    WHEN exp_export_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ' || SQLERRM
                                              ,pkg_gate.event_error);
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при эспорте данных '
                                              ,pkg_gate.event_error);
    WHEN exp_pack_err THEN
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ' || SQLERRM
                                              ,pkg_gate.event_error);
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ошибка при эспорте пакета '
                                              ,pkg_gate.event_error);
    WHEN OTHERS THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.Job: ' || SQLERRM
                                              ,pkg_gate.event_error);
  END Job;

  FUNCTION GetStrColumn(tab_name VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_t(p_tab_name VARCHAR2) IS
      SELECT COUNT(*) over(PARTITION BY cols.table_name) AS c
            ,cols.column_id
            ,cols.column_name AS NAME
        FROM sys.user_tab_columns cols
       WHERE cols.table_name = p_tab_name
       ORDER BY column_id;
  
    ret VARCHAR2(1000) := ' ';
  BEGIN
    FOR rec IN cur_t(tab_name)
    LOOP
      ret := ret || rec.name;
      IF (rec.c <> rec.column_id)
      THEN
        ret := ret || ',';
      END IF;
    END LOOP;
    RETURN ret;
  END;

  /* работает чере Ref cursors и NDS*/
  PROCEDURE JobImport IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    TYPE t_ref_cur IS REF CURSOR;
    ref_cursor t_ref_cur;
  
    CURSOR gate_ex(p_type IN NUMBER) IS
      SELECT * FROM GATE_OBJ_EXPORT_LINE WHERE GATE_OBJ_TYPE_ID = p_type ORDER BY NUM_EXE ASC;
  
    rec_package GATE_IN_PACKAGE%ROWTYPE;
  
    pack_name VARCHAR2(32);
    res_fun   NUMBER := 0;
  
    imp_pack_del_err    EXCEPTION;
    imp_process_err     EXCEPTION;
    imp_pack_status_err EXCEPTION;
    imp_pack_err        EXCEPTION;
    imp_data_err        EXCEPTION;
  
  BEGIN
  
    LOOP
      OPEN ref_cursor FOR 'select * from GATE_IN_PACKAGE@gatebi where PACK_STATUS = ' /*|| pkg_gate.pkg_state_loading */
      || '11 order by GATE_PACKAGE_ID asc';
    
      FETCH ref_cursor
        INTO rec_package;
      EXIT WHEN ref_cursor%NOTFOUND;
      CLOSE ref_cursor;
    
      COMMIT;
    
      res_fun := pkg_gate.ImportPackage(rec_package);
      IF (res_fun != Utils.c_true)
      THEN
        RAISE imp_pack_err;
      END IF;
    
      pack_name := pkg_gate.GetPack(rec_package.GATE_OBJ_TYPE_ID);
    
      FOR rec_ex IN gate_ex(rec_package.GATE_OBJ_TYPE_ID)
      LOOP
        res_fun := Export(rec_ex.EXPORT_LINE, rec_package.GATE_PACKAGE_ID, TRUE);
        IF (res_fun = Utils.c_false)
        THEN
          RAISE imp_data_err;
        END IF;
      END LOOP;
    
      EXECUTE IMMEDIATE 'BEGIN :val1:=' || pack_name || '.PrepareData_process; END;'
        USING OUT res_fun;
    
      IF (res_fun = Utils.c_false)
      THEN
        RAISE imp_process_err;
      END IF;
    
      res_fun := pkg_gate.SetImpPackageStatus(rec_package.GATE_PACKAGE_ID, pkg_gate.pkg_state_comlite);
      IF (res_fun = Utils.c_false)
      THEN
        RAISE imp_pack_status_err;
      END IF;
    
      res_fun := pkg_gate.DelImpPackage(rec_package.GATE_PACKAGE_ID);
      IF (res_fun = Utils.c_false)
      THEN
        RAISE imp_pack_del_err;
      END IF;
    END LOOP;
  
    COMMIT;
  EXCEPTION
    WHEN imp_pack_del_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.JobImport: ошибка при удалении пакета'
                                              ,pkg_gate.event_error);
    WHEN imp_process_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.JobImport: ошибка при работе пакета конвертации данных'
                                              ,pkg_gate.event_error);
    WHEN imp_pack_status_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.JobImport: ошибка при назначении статуса пакету'
                                              ,pkg_gate.event_error);
    WHEN imp_pack_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.JobImport: ошибка при импорте пакета'
                                              ,pkg_gate.event_error);
    WHEN imp_data_err THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.JobImport: ошибка при импорте данных'
                                              ,pkg_gate.event_error);
    WHEN OTHERS THEN
      ROLLBACK;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_EXPORT.JobImport: ' || SQLERRM
                                              ,pkg_gate.event_error);
  END JobImport;

END PKG_GATE_EXPORT;
/

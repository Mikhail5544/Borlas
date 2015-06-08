CREATE OR REPLACE PACKAGE PKG_GATE_TEMP IS
  row_insert     CONSTANT NUMBER := 0;
  row_update     CONSTANT NUMBER := 1;
  row_delete     CONSTANT NUMBER := 2;
  row_err        CONSTANT NUMBER := 3;
  row_none       CONSTANT NUMBER := 4;
  row_export     CONSTANT NUMBER := 5;
  row_pre_export CONSTANT NUMBER := 6;

  pkg_state_creating CONSTANT NUMBER := 10;
  pkg_state_loading  CONSTANT NUMBER := 11;
  pkg_state_comlite  CONSTANT NUMBER := 12;

  FUNCTION get_insert RETURN NUMBER;
  FUNCTION get_update RETURN NUMBER;
  FUNCTION get_delete RETURN NUMBER;

  event_info  CONSTANT NUMBER := 0;
  event_error CONSTANT NUMBER := 1;

  /*  OT_Agent constant number:= 1; --агенты
  OT_Agency constant number:= 2; --агенства
  OT_AgReport constant number:= 20; --выплаты агентам
  OT_ProdLine constant number:= 30; --ProLine
  OT_AcPayOrder constant number:= 40; --  Распоряжения на выплату возмещения
  OT_Peril constant number:= 50; -- Вид риска
  OT_AcPayOrdBack constant number:= 60; -- Распоряжение на выплату возврата по ПС
  */

  --  PROCESS_GATE_STATUS
  pgs_none       CONSTANT NUMBER := -1;
  pgs_starting   CONSTANT NUMBER := 0;
  pgs_processing CONSTANT NUMBER := 1;
  pgs_finishing  CONSTANT NUMBER := 2;
  pgs_error      CONSTANT NUMBER := 3;
  pgs_complite   CONSTANT NUMBER := 4;
  pgs_run_export CONSTANT NUMBER := 5;

  pdc_table   CONSTANT NUMBER := 0;
  pdc_package CONSTANT NUMBER := 1;

  EventRet NUMBER;
  ResFun   NUMBER;

  gate_debug NUMBER := Utils_tmp.c_true;

  FUNCTION InserEvent
  (
    p_mess       VARCHAR2
   ,p_type       NUMBER
   ,p_obj_type   NUMBER DEFAULT 2000
   ,p_package_id NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  PROCEDURE ChangeRow
  (
    p_type_status NUMBER
   ,p_obj_type    NUMBER
   ,p_id          NUMBER
   ,p_ent_id      NUMBER
   ,p_tr_name     VARCHAR2 DEFAULT NULL
  );
  --  procedure SetStatusRow(p_obj_id number, p_status number);

  -- статусы процессов - возвращают Utils.c_false в случае ошибки, иначе возвращают c_true
  FUNCTION SetStatusProcess
  (
    p_type_process NUMBER
   ,p_status       NUMBER
  ) RETURN NUMBER;
  FUNCTION SetStatusProcessStarting(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION SetStatusProcessProcessing(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION SetStatusProcessFinishing(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION SetStatusProcessError(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION SetStatusProcessComplite(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION SetStatusProcessExport(p_type_process NUMBER) RETURN NUMBER;

  FUNCTION GetStatusProcess(p_type_process NUMBER) RETURN NUMBER;

  -- управление процессами
  FUNCTION InitJobs RETURN NUMBER;
  FUNCTION ClearJobs RETURN NUMBER;
  FUNCTION RepairJobs RETURN NUMBER;

  -- Управление пакетами на стороне BI
  FUNCTION CreatePackage
  (
    p_new_package OUT NUMBER
   ,p_type        IN NUMBER
  ) RETURN NUMBER;
  FUNCTION SetPackageStatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER;
  FUNCTION GetPackageStatus
  (
    p_pkg   NUMBER
   ,p_state OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION HistoryPackage
  (
    p_pkg          NUMBER
   ,p_name_package VARCHAR2
  ) RETURN NUMBER;
  FUNCTION ExportPackage(p_pkg NUMBER) RETURN NUMBER;
  FUNCTION ImportPackage(p_pkg GATE_PACKAGE%ROWTYPE) RETURN NUMBER;
  FUNCTION SetImpPackageStatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER;
  FUNCTION DelImpPackage(p_pkg NUMBER) RETURN NUMBER;

  -- Удаление всех пакетов, и как следствие удаление всех данных
  FUNCTION ClearAllPackage RETURN NUMBER;
  -- Удаление всех пакетов истории, и как следствие удаление всех данных
  FUNCTION ClearAllPackage_history RETURN NUMBER;
  -- Управление пакетами на стороне MSSQL
  FUNCTION SetPackageStatusMSSQL
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER;
  -- упралвение транзакциями -- не работают!
  -- управление транзакциями осуществляется через стандратный механиз
  -- автономных транзакций в оракле.
  FUNCTION Begin_Trn RETURN NUMBER;
  FUNCTION Commit_Trn RETURN NUMBER;
  FUNCTION Rollback_Trn RETURN NUMBER;

  -- упраление самим гейтом
  -- Включение, выключение
  FUNCTION Turn(p_on_off NUMBER) RETURN NUMBER;
  -- компиляция  -- пока пустая
  FUNCTION CompileGate RETURN NUMBER;
  -- перезапуск гейта!- удаления всех данных, переинициализация всех джобов, удаление джобов
  FUNCTION ReInstall RETURN NUMBER;

  -- утилитки
  -- вычисляет следущую дату через заданный интервал
  FUNCTION GetNextDate(p_minuts INT) RETURN DATE;

  -- кустомицизация процессов
  PROCEDURE StartProcess(p_type IN NUMBER);
  FUNCTION GetPack(p_type IN NUMBER) RETURN VARCHAR2;
  FUNCTION RunProcess(p_type IN NUMBER) RETURN NUMBER;
  FUNCTION PrepareData
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
   ,is_have_data     IN OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION PrepareData_process
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER;
  FUNCTION InsertMessage_Gate
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER;
  FUNCTION DeleteMessage_Gate(id_pac IN NUMBER) RETURN NUMBER;
  FUNCTION Finishing
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER;
  FUNCTION SynchronizeGate RETURN NUMBER;
  FUNCTION RunProcessOnTree(p_type IN NUMBER) RETURN NUMBER;

  -- улитики
  FUNCTION GetDocumentTempl
  (
    p_doc_templ NUMBER
   ,p_ret_val   OUT DOC_TEMPL%ROWTYPE
  ) RETURN NUMBER;
  FUNCTION GetDocTemplByDocId
  (
    p_doc_id  NUMBER
   ,p_ret_val OUT DOC_TEMPL%ROWTYPE
  ) RETURN NUMBER;

  PROCEDURE CreateNewEnt
  (
    p_type_name   VARCHAR2
   ,p_type        NUMBER
   ,p_parent_type NUMBER
  );
  PROCEDURE AddExportLine
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_num_exe     NUMBER
  );
  PROCEDURE AddPrepareData
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_tab_name    VARCHAR2
   ,p_num_exe     NUMBER
  );
  PROCEDURE AddProcessGate
  (
    p_type   NUMBER
   ,p_proc   VARCHAR2
   ,p_period VARCHAR2
  );

  --
  FUNCTION ExportAllObjects(p_type NUMBER) RETURN NUMBER;
  --2009.04.14  А. Герасимов процедуры копирования ППВХ
  PROCEDURE xx_gap_copy_main;
  PROCEDURE xx_gap_copy
  (
    p_row_status     IN NUMBER
   ,p_tab_for_insert IN VARCHAR2
   ,p_code           IN NUMBER
  );
  PROCEDURE xx_gap_main;
  PROCEDURE xx_gap_process;
  PROCEDURE xx_gap_process_new;
END PKG_GATE_TEMP;
/
CREATE OR REPLACE PACKAGE BODY PKG_GATE_TEMP IS
  FUNCTION get_insert RETURN NUMBER IS
  BEGIN
    RETURN row_insert;
  END;

  FUNCTION get_update RETURN NUMBER IS
  BEGIN
    RETURN row_update;
  END;

  FUNCTION get_delete RETURN NUMBER IS
  BEGIN
    RETURN row_delete;
  END;

  FUNCTION InserEvent
  (
    p_mess       VARCHAR2
   ,p_type       NUMBER
   ,p_obj_type   NUMBER DEFAULT 2000
   ,p_package_id NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  
    IF (p_type = event_info AND gate_debug = Utils_tmp.c_false)
    THEN
      COMMIT;
      RETURN Utils_tmp.c_true;
    END IF;
  
    INSERT INTO GATE_EVENT
      (GATE_EVENT_ID
      ,MESSAGE_EVENT
      ,GATE_EVENT_TYPE_ID
      ,MESSAGE_DATE
      ,GATE_OBJ_TYPE_ID
      ,GATE_PACKAGE_ID
      ,BACK_SEND)
    VALUES
      (SQ_GATE_EVENT.NEXTVAL, p_mess, p_type, SYSDATE, p_obj_type, p_package_id, NULL);
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN Utils_tmp.c_false;
  END;

  PROCEDURE ChangeRow
  (
    p_type_status NUMBER
   ,p_obj_type    NUMBER
   ,p_id          NUMBER
   ,p_ent_id      NUMBER
   ,p_tr_name     VARCHAR2 DEFAULT NULL
  ) IS
    res    NUMBER;
    r_date DATE := SYSDATE;
  BEGIN
    IF (gate_debug = Utils_tmp.c_false)
    THEN
      r_date := NULL;
    END IF;
    INSERT INTO GATE_OBJ
      (GATE_OBJ_ID, GATE_OBJ_TYPE_ID, ID, GATE_ROW_STATUS_ID, TR_NAME, ROW_DATE, ENT_ID)
    VALUES
      (SQ_GATE_OBJ.NEXTVAL, p_obj_type, p_id, p_type_status, p_tr_name, r_date, p_ent_id);
  EXCEPTION
    WHEN OTHERS THEN
      res := InserEvent('ChangeRow - trigger (' || p_tr_name || ') : ' || SQLERRM, event_error);
  END;
  ----------------------
  -- Определяет (записывает) статус процесса.
  ----------------------
  FUNCTION SetStatusProcess
  (
    p_type_process NUMBER
   ,p_status       NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR get_cur_status(pc_type_process NUMBER) IS
      SELECT * FROM PROCESS_GATE_RUN P WHERE P.GATE_OBJ_TYPE_ID = pc_type_process;
    get_rec_status get_cur_status%ROWTYPE;
  BEGIN
    OPEN get_cur_status(p_type_process);
    FETCH get_cur_status
      INTO get_rec_status;
  
    IF (get_cur_status%NOTFOUND)
    THEN
      INSERT INTO process_gate_run
        (gate_obj_type_id, process_gate_status, STATUS_DATE)
      VALUES
        (p_type_process, p_status, SYSDATE);
    END IF;
  
    IF (get_cur_status%FOUND)
    THEN
      UPDATE process_gate_run p
         SET p.process_gate_status = p_status
            ,STATUS_DATE           = SYSDATE
       WHERE p.gate_obj_type_id = p_type_process;
    END IF;
  
    CLOSE get_cur_status;
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := InserEvent('SetStatusProcess:' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END SetStatusProcess;

  FUNCTION SetStatusProcessStarting(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SetStatusProcess(p_type_process, pgs_starting);
  END;

  FUNCTION SetStatusProcessProcessing(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SetStatusProcess(p_type_process, pgs_processing);
  END;

  FUNCTION SetStatusProcessFinishing(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SetStatusProcess(p_type_process, pgs_finishing);
  END;

  FUNCTION SetStatusProcessError(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SetStatusProcess(p_type_process, pgs_error);
  END;

  FUNCTION SetStatusProcessComplite(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SetStatusProcess(p_type_process, pgs_complite);
  END;

  FUNCTION SetStatusProcessExport(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SetStatusProcess(p_type_process, pgs_complite);
  END;

  FUNCTION GetStatusProcess(p_type_process NUMBER) RETURN NUMBER IS
    CURSOR get_cur_status(pc_type_process NUMBER) IS
      SELECT * FROM PROCESS_GATE_RUN P WHERE P.GATE_OBJ_TYPE_ID = pc_type_process;
    get_rec_status get_cur_status%ROWTYPE;
    res            NUMBER := pgs_none;
  BEGIN
    OPEN get_cur_status(p_type_process);
    FETCH get_cur_status
      INTO get_rec_status;
    IF (get_cur_status%FOUND)
    THEN
      res := get_rec_status.PROCESS_GATE_STATUS;
    END IF;
    CLOSE get_cur_status;
    RETURN res;
  END;

  FUNCTION ClearJob(p_jobno NUMBER) RETURN NUMBER IS
  BEGIN
    DBMS_JOB.REMOVE(p_jobno);
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.ClearJob: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END ClearJob;

  FUNCTION InitJobs RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    /*процессы должны инициализироваться по древовидной архитектуре,
    иначе одни процессы могут раньше инициализироваться чем их предки*/
    CURSOR proc_table IS
      SELECT p.*
        FROM process_gate  p
            ,gate_obj_type got
       WHERE got.gate_obj_type_id = p.gate_obj_type_id
      CONNECT BY got.parent_id = PRIOR got.gate_obj_type_id
       START WITH got.parent_id IS NULL;
  
    CURSOR state_table IS
      SELECT * FROM PROCESS_GATE_RUN P WHERE P.PROCESS_GATE_STATUS NOT IN (pgs_complite, pgs_error);
  
    rec_state_table state_table%ROWTYPE;
  
    nds_block VARCHAR2(255);
    jobno     NUMBER;
    proc_is_runing EXCEPTION;
    fun_res NUMBER;
    i       NUMBER := 1;
  BEGIN
    OPEN state_table;
    FETCH state_table
      INTO rec_state_table;
  
    IF (state_table%FOUND)
    THEN
      CLOSE state_table;
      RAISE proc_is_runing;
    END IF;
  
    CLOSE state_table;
  
    DELETE FROM PROCESS_GATE_RUN;
  
    FOR rec_proc IN proc_table
    LOOP
      IF (rec_proc.JOB_NUM IS NOT NULL)
      THEN
        fun_res := ClearJob(rec_proc.JOB_NUM);
      END IF;
      jobno := NULL;
    
      DBMS_JOB.SUBMIT(jobno, rec_proc.proc, getNextDate(i), rec_proc.period);
      EventRet := InserEvent('PKG_GATE.InitJobs: инициализирован JOB (' || jobno ||
                             ') для типа процесс (' || rec_proc.gate_obj_type_id || ')'
                            ,event_error);
      UPDATE PROCESS_GATE
         SET JOB_NUM   = jobno
            ,LAST_DATE = SYSDATE
       WHERE GATE_OBJ_TYPE_ID = rec_proc.GATE_OBJ_TYPE_ID;
    
      i := i + 1;
    END LOOP;
  
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN proc_is_runing THEN
      EventRet := InserEvent('PKG_GATE.InitJobs: процессы запущены', event_error);
      RETURN Utils_tmp.c_false;
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.InitJobs: ' || SQLERRM, event_error);
      ROLLBACK;
      RETURN Utils_tmp.c_false;
  END InitJobs;

  FUNCTION ClearJobs RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR proc_table IS
      SELECT * FROM PROCESS_GATE;
  BEGIN
    FOR rec_proc IN proc_table
    LOOP
      IF (rec_proc.JOB_NUM IS NOT NULL)
      THEN
        DBMS_JOB.REMOVE(rec_proc.JOB_NUM);
        UPDATE PROCESS_GATE SET JOB_NUM = NULL WHERE GATE_OBJ_TYPE_ID = rec_proc.GATE_OBJ_TYPE_ID;
      END IF;
    END LOOP;
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.ClearJobs: ' || SQLERRM, event_error);
      ROLLBACK;
      RETURN Utils_tmp.c_false;
  END ClearJobs;

  FUNCTION RepairJobs RETURN NUMBER IS
  BEGIN
    DELETE FROM PROCESS_GATE_RUN PGR WHERE PGR.PROCESS_GATE_STATUS = pgs_error;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.RepairJobs: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END;

  -- Управление пакетами
  FUNCTION CreatePackage
  (
    p_new_package OUT NUMBER
   ,p_type        IN NUMBER
  ) RETURN NUMBER IS
    res_new_sq NUMBER;
  BEGIN
    SELECT SQ_GATE_PACKAGE.nextval INTO res_new_sq FROM dual;
  
    INSERT INTO GATE_PACKAGE
      (GATE_PACKAGE_ID, PACK_DATE_CREATE, PACK_STATUS, GATE_OBJ_TYPE_ID)
    VALUES
      (res_new_sq, SYSDATE, pkg_state_creating, p_type);
  
    p_new_package := res_new_sq;
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := InserEvent('PKG_GATE.CreatePackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END CreatePackage;

  FUNCTION HistoryPackage
  (
    p_pkg          NUMBER
   ,p_name_package VARCHAR2
  ) RETURN NUMBER IS
    p_state NUMBER;
    state_invalid EXCEPTION;
    history_err   EXCEPTION;
  BEGIN
  
    -- пакет помечается как отработанный
    ResFun := GetPackageStatus(p_pkg, p_state);
    IF (ResFun = Utils_tmp.c_false)
    THEN
      RETURN Utils_tmp.c_false;
    END IF;
  
    IF (p_state != pkg_state_loading)
    THEN
      RAISE state_invalid;
    END IF;
  
    -- пакет передается в историю
    INSERT INTO gate_package_history
      (gate_package_id, pack_date_create, pack_date_load, pack_date_complite, pack_status)
      SELECT g.gate_package_id
            ,g.pack_date_create
            ,g.pack_date_load
            ,g.pack_date_complite
            ,pkg_state_loading
        FROM gate_package g
       WHERE gate_package_id = p_pkg;
  
    INSERT INTO gate_obj_history
      (ID, gate_obj_type_id, gate_row_status_id, gate_package_id)
      SELECT gos.ID
            ,gos.gate_obj_type_id
            ,gos.gate_row_status_id
            ,gos.gate_package_id
        FROM gate_obj_statistics gos
       WHERE gos.gate_package_id = p_pkg;
  
    ResFun := SetPackageStatus(p_pkg, pkg_state_comlite);
    IF (ResFun = Utils_tmp.c_false)
    THEN
      RETURN Utils_tmp.c_false;
    END IF;
  
    -- пакет в истории помечается как отработанный
    UPDATE gate_package_history g
       SET g.pack_date_complite = SYSDATE
          ,g.pack_status        = pkg_state_comlite
     WHERE g.gate_package_id = p_pkg;
  
    -- удаляется основной пакет, по каскадным ссылкам уходят все данные автоматически
    DELETE FROM GATE_PACKAGE WHERE gate_package_id = p_pkg;
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN history_err THEN
      EventRet := InserEvent('PKG_GATE.HistoryPackage: неопределенная ошибка при запуске истории в друго пакете'
                            ,event_error);
      RETURN Utils_tmp.c_false;
    WHEN state_invalid THEN
      EventRet := InserEvent('PKG_GATE.HistoryPackage: пакет находиться не в загруженом состоянии'
                            ,event_error);
      RETURN Utils_tmp.c_false;
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.HistoryPackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END HistoryPackage;

  FUNCTION GetPackageStatus
  (
    p_pkg   NUMBER
   ,p_state OUT NUMBER
  ) RETURN NUMBER IS
    CURSOR cur_pkg IS
      SELECT * FROM GATE_PACKAGE WHERE GATE_PACKAGE_ID = p_pkg;
  
    rec_pkg cur_pkg%ROWTYPE;
    rec_notfound EXCEPTION;
    res NUMBER;
  BEGIN
    OPEN cur_pkg;
    FETCH cur_pkg
      INTO rec_pkg;
  
    IF (cur_pkg%NOTFOUND)
    THEN
      CLOSE cur_pkg;
      RAISE rec_notfound;
    END IF;
  
    res := rec_pkg.PACK_STATUS;
  
    CLOSE cur_pkg;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.GetPackageStatus: не найден пакет', event_error);
      RETURN Utils_tmp.c_false;
  END;

  FUNCTION SetPackageStatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER IS
  BEGIN
    CASE p_state
      WHEN pkg_state_creating THEN
        UPDATE GATE_PACKAGE
           SET PACK_DATE_CREATE = SYSDATE
              ,PACK_STATUS      = p_state
         WHERE GATE_PACKAGE_ID = p_pkg;
      WHEN pkg_state_loading THEN
        UPDATE GATE_PACKAGE
           SET PACK_DATE_LOAD = SYSDATE
              ,PACK_STATUS    = p_state
         WHERE GATE_PACKAGE_ID = p_pkg;
      WHEN pkg_state_comlite THEN
        UPDATE GATE_PACKAGE
           SET PACK_DATE_COMPLITE = SYSDATE
              ,PACK_STATUS        = p_state
         WHERE GATE_PACKAGE_ID = p_pkg;
    END CASE;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.SetPackageStatus: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END;

  FUNCTION ExportPackage(p_pkg NUMBER) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    CURSOR cur_package IS
      SELECT * FROM gate_package WHERE gate_package_id = p_pkg;
  
    rec_package cur_package%ROWTYPE;
  
    p_d     DATE := SYSDATE;
    pac_c   NUMBER := 0;
    pac_s   NUMBER := 0;
    sql_str VARCHAR2(4000);
  BEGIN
  
    OPEN cur_package;
    FETCH cur_package
      INTO rec_package;
  
    EventRet := InserEvent('PKG_GATE.ExportPackage 1 PACK_NUM = ' || p_pkg, event_info);
  
    IF (cur_package%NOTFOUND)
    THEN
      CLOSE cur_package;
      RETURN Utils_tmp.c_false;
    END IF;
  
    EventRet := InserEvent('PKG_GATE.ExportPackage 2 PACK_NUM = ' || p_pkg, event_info);
  
    --  sql_str := ' INSERT INTO gate_package@gatebi(gate_package_id,pack_date_create,pack_status,gate_obj_type_id) '
    --          ||' values ('||p_pkg||',TO_DATE(''dd.mm.yyyy'','''||rec_package.PACK_DATE_CREATE||'''),'||pkg_state_creating||','||rec_package.GATE_OBJ_TYPE_ID||') ';
  
    BEGIN
      EXECUTE IMMEDIATE ' select pack_status from gate_package@gatebi where gate_package_id = ' ||
                        p_pkg
        INTO pac_s;
    EXCEPTION
      WHEN no_data_found THEN
        pac_s := 0;
    END;
  
    -- возможно состояние, когда пакет создан на другой стороне и имеет состояние ошибочное,
    -- и поэтому новая вставка невозможна, необходимо его там удалить
    IF (pac_s IS NOT NULL AND pac_s = pkg_state_creating)
    THEN
      EventRet := InserEvent('PKG_GATE.ExportPackage: исправление пакета началось ' || p_pkg
                            ,event_info);
      EXECUTE IMMEDIATE 'delete from gate_package@gatebi where gate_package_id = :val1'
        USING IN p_pkg;
      EventRet := InserEvent('PKG_GATE.ExportPackage: исправление пакета закончилось успешно' || p_pkg
                            ,event_info);
    END IF;
  
    EXECUTE IMMEDIATE ' INSERT INTO gate_package@gatebi(gate_package_id,pack_date_create,pack_status,gate_obj_type_id) ' ||
                      ' values (:val1,:val2,:val3,:val4) '
      USING IN p_pkg, IN rec_package.PACK_DATE_CREATE, IN pkg_state_creating, IN rec_package.GATE_OBJ_TYPE_ID;
  
    CLOSE cur_package;
  
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := InserEvent('PKG_GATE.ExportPackage: SQL - ' || sql_str, event_error);
      EventRet := InserEvent('PKG_GATE.ExportPackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END;

  FUNCTION ImportPackage(p_pkg GATE_PACKAGE%ROWTYPE) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    CURSOR cur_pack_in(P_GATE_PACKAGE_ID NUMBER) IS
      SELECT * FROM gate_in_package g WHERE g.GATE_PACKAGE_ID = P_GATE_PACKAGE_ID;
  
    p_d DATE := SYSDATE;
  
    rec_pack_in cur_pack_in%ROWTYPE;
  
  BEGIN
    OPEN cur_pack_in(p_pkg.GATE_PACKAGE_ID);
    FETCH cur_pack_in
      INTO rec_pack_in;
  
    IF (cur_pack_in%FOUND)
    THEN
      -- найден пакет. проверяется его статус, если статус что загружается, то удаляем его!
      IF (rec_pack_in.PACK_STATUS = pkg_state_creating)
      THEN
        EventRet := InserEvent('PKG_GATE.InportPackage: Найден ошибочный пакет, пытаемся его удалить' ||
                               rec_pack_in.GATE_PACKAGE_ID
                              ,event_info);
        DELETE FROM gate_in_package WHERE GATE_PACKAGE_ID = rec_pack_in.GATE_PACKAGE_ID;
        COMMIT;
        EventRet := InserEvent('PKG_GATE.InportPackage: Ошибочный пакет удален' ||
                               rec_pack_in.GATE_PACKAGE_ID
                              ,event_info);
      ELSE
        EventRet := InserEvent('PKG_GATE.InportPackage: Пакет с таким номером, уже зарегистрирован в шлюзе.' ||
                               rec_pack_in.GATE_PACKAGE_ID
                              ,event_error);
        CLOSE cur_pack_in;
        RETURN Utils_tmp.c_false;
      END IF;
    END IF;
  
    CLOSE cur_pack_in;
  
    INSERT INTO gate_in_package
      (GATE_PACKAGE_ID
      ,PACK_DATE_CREATE
      ,PACK_STATUS
      ,GATE_OBJ_TYPE_ID
      ,PACK_DATE_LOAD
      ,PACK_DATE_COMPLITE)
    VALUES
      (p_pkg.GATE_PACKAGE_ID
      ,p_d
      ,pkg_state_creating
      ,p_pkg.GATE_OBJ_TYPE_ID
      ,p_pkg.PACK_DATE_LOAD
      ,p_pkg.PACK_DATE_COMPLITE);
  
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := InserEvent('PKG_GATE.InportPackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END ImportPackage;

  FUNCTION DelImpPackage(p_pkg NUMBER) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE 'delete from GATE_IN_PACKAGE@gatebi where GATE_PACKAGE_ID = ' || p_pkg;
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := InserEvent('PKG_GATE.InportPackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END DelImpPackage;

  FUNCTION SetImpPackageStatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    CASE p_state
      WHEN pkg_state_creating THEN
        UPDATE GATE_IN_PACKAGE
           SET PACK_DATE_CREATE = SYSDATE
              ,PACK_STATUS      = p_state
         WHERE GATE_PACKAGE_ID = p_pkg;
      WHEN pkg_state_loading THEN
        UPDATE GATE_IN_PACKAGE
           SET PACK_DATE_LOAD = SYSDATE
              ,PACK_STATUS    = p_state
         WHERE GATE_PACKAGE_ID = p_pkg;
      WHEN pkg_state_comlite THEN
        UPDATE GATE_IN_PACKAGE
           SET PACK_DATE_COMPLITE = SYSDATE
              ,PACK_STATUS        = p_state
         WHERE GATE_PACKAGE_ID = p_pkg;
    END CASE;
  
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := InserEvent('PKG_GATE.InportPackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END SetImpPackageStatus;

  FUNCTION SetObjStatus
  (
    p_on_off   NUMBER
   ,p_name_obj VARCHAR2
   ,p_type     VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    CASE p_type
      WHEN 'TRIGGER' THEN
        BEGIN
          IF (p_on_off = Utils_tmp.c_true)
          THEN
            EXECUTE IMMEDIATE 'alter trigger ' || p_name_obj || ' enable';
          ELSE
            EXECUTE IMMEDIATE 'alter trigger ' || p_name_obj || ' disable';
          END IF;
        END;
    END CASE;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.SetObjStatus: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END SetObjStatus;

  FUNCTION Turn(p_on_off NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rec IN (SELECT s.OBJECT_TYPE
                      ,s.OBJECT_NAME
                  FROM sys.user_objects s
                      ,GATE_SYS_OBJ     GSO
                 WHERE GSO.SYS_OBJ_NAME = s.OBJECT_NAME)
    LOOP
      ResFun := SetObjStatus(p_on_off, rec.OBJECT_NAME, rec.OBJECT_TYPE);
      IF (ResFun = Utils_tmp.c_false)
      THEN
        RETURN Utils_tmp.c_false;
      END IF;
    END LOOP;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.Turn: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END;

  -- компиляция  -- пока пустая
  FUNCTION CompileGate RETURN NUMBER IS
    CURSOR cur_prep IS
      SELECT * FROM GATE_OBJ_PREPARE_DATA;
  
    CURSOR cur_wrap
    (
      p_tab1 VARCHAR2
     ,p_tab2 VARCHAR2
    ) IS
      SELECT B.COLUMN_NAME        AS B
            ,B.internal_column_id AS B1
            ,B.data_type          AS B2
            ,A.COLUMN_NAME        AS A
            ,A.internal_column_id AS A1
            ,A.data_type          AS A2
        FROM all_tab_cols A
            ,all_tab_cols B
       WHERE B.table_name = p_tab1
         AND A.table_name = p_tab2
         AND a.INTERNAL_COLUMN_ID = B.INTERNAL_COLUMN_ID
         AND a.DATA_TYPE <> B.DATA_TYPE;
  
  BEGIN
    FOR rec IN cur_prep
    LOOP
      FOR rec_w IN cur_wrap(rec.EXPORT_LINE, rec.EXPORT_TAB)
      LOOP
        EventRet := InserEvent('Ошибка данные отличаются ' || rec.EXPORT_LINE || ' -> ' ||
                               rec.EXPORT_TAB
                              ,event_error);
        EventRet := InserEvent(rec_w.B || '.' || rec_w.B1 || '.' || rec_w.B2 || ' -> ' || rec_w.A || '.' ||
                               rec_w.A1 || '.' || rec_w.A2
                              ,event_error);
      END LOOP;
    END LOOP;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.CompileGate: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END CompileGate;

  FUNCTION ReInstall RETURN NUMBER IS
  BEGIN
    DELETE FROM GATE_PACKAGE_HISTORY;
    DELETE FROM GATE_PACKAGE;
    DELETE FROM GATE_OBJ;
  
    ResFun := ClearJobs;
    ResFun := InitJobs;
  
    DELETE FROM GATE_EVENT;
    EventRet := InserEvent('PKG_GATE.ReInstall: GATE перестартовал успешно ' || SQLERRM
                          ,event_info);
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.ReInstall: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END ReInstall;

  FUNCTION Begin_Trn RETURN NUMBER IS
    fn_res NUMBER;
  BEGIN
    -- fn_res := DBMS_HS_PASSTHROUGH.EXECUTE_IMMEDIATE@GATEBI('begin transaction');
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.Begin_Trn: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END Begin_Trn;

  FUNCTION Rollback_Trn RETURN NUMBER IS
    fn_res NUMBER;
  BEGIN
    --fn_res := DBMS_HS_PASSTHROUGH.EXECUTE_IMMEDIATE@GATEBI('ROLLBACK');
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.Commit_Trn: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END Rollback_Trn;

  FUNCTION Commit_Trn RETURN NUMBER IS
    fn_res NUMBER;
  BEGIN
    --fn_res := DBMS_HS_PASSTHROUGH.EXECUTE_IMMEDIATE@GATEBI('COMMIT');
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.Commit_Trn: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END Commit_Trn;

  FUNCTION SetPackageStatusMSSQL
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    ex_fn   VARCHAR2(30);
    ip_date DATE;
  BEGIN
    SELECT SYSDATE INTO ip_date FROM dual;
    CASE p_state
      WHEN pkg_state_creating THEN
        EXECUTE IMMEDIATE 'update GATE_PACKAGE@GATEBI set PACK_DATE_CREATE =  :val1, PACK_STATUS =  ' ||
                          p_state || ' where GATE_PACKAGE_ID = ' || p_pkg
          USING IN ip_date;
      WHEN pkg_state_loading THEN
        EXECUTE IMMEDIATE 'update GATE_PACKAGE@GATEBI set PACK_DATE_LOAD =  :val1, PACK_STATUS =  ' ||
                          p_state || ' where GATE_PACKAGE_ID = ' || p_pkg
          USING IN ip_date;
      WHEN pkg_state_comlite THEN
        EXECUTE IMMEDIATE 'update GATE_PACKAGE@GATEBI set PACK_DATE_COMPLITE =  :val1, PACK_STATUS =  ' ||
                          p_state || ' where GATE_PACKAGE_ID = ' || p_pkg
          USING IN ip_date;
    END CASE;
    COMMIT;
    RETURN Utils_tmp.c_true;
  END;

  FUNCTION ClearAllPackage RETURN NUMBER IS
  BEGIN
    DELETE FROM GATE_PACKAGE;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.ClearAllPackage: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END ClearAllPackage;

  FUNCTION ClearAllPackage_history RETURN NUMBER IS
  BEGIN
    DELETE FROM GATE_PACKAGE_HISTORY;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := InserEvent('PKG_GATE.ClearAllPackage_history: ' || SQLERRM, event_error);
      RETURN Utils_tmp.c_false;
  END ClearAllPackage_history;

  FUNCTION GetNextDate(p_minuts INT) RETURN DATE IS
    res DATE;
  BEGIN
    SELECT TRUNC(SYSDATE) +
           (TRUNC(TO_CHAR(SYSDATE, 'sssss') / (p_minuts * 60)) + 1) * p_minuts / 24 / 60
      INTO res
      FROM DUAL;
    RETURN res;
  END GetNextDate;

  FUNCTION RunProcessOnTree(p_type IN NUMBER) RETURN NUMBER IS
    CURSOR cur_pr(pc_type NUMBER) IS
      SELECT *
        FROM GATE_OBJ_TYPE GOT
       WHERE GOT.GATE_OBJ_TYPE_ID <> p_type
      CONNECT BY GOT.GATE_OBJ_TYPE_ID = PRIOR GOT.PARENT_ID
       START WITH GOT.GATE_OBJ_TYPE_ID = pc_type;
  
    rec_pr cur_pr%ROWTYPE;
  BEGIN
    OPEN cur_pr(p_type);
    FETCH cur_pr
      INTO rec_pr;
  
    IF (cur_pr%FOUND)
    THEN
      StartProcess(rec_pr.GATE_OBJ_TYPE_ID);
    END IF;
  
    CLOSE cur_pr;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.RunProcessOnTree(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
    
  END RunProcessOnTree;

  PROCEDURE StartProcess(p_type IN NUMBER) IS
    res_s    NUMBER;
    res_proc NUMBER;
    res_fun  NUMBER;
    proc_err          EXCEPTION;
    proc_error_status EXCEPTION;
    proc_tree_err     EXCEPTION;
  BEGIN
  
    res_s := pkg_gate.GetStatusProcess(p_type);
    IF (res_s = pkg_gate.pgs_none OR res_s = pkg_gate.pgs_complite)
    THEN
      res_fun := pkg_gate.SetStatusProcessStarting(p_type);
    ELSE
      --raise proc_err;
      RETURN;
    END IF;
  
    res_fun := RunProcessOnTree(p_type);
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RAISE proc_tree_err;
    END IF;
  
    --EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess('||p_type||'): Стартанули ',pkg_gate.event_error);
    res_proc := RunProcess(p_type);
  
    IF (res_proc = Utils_tmp.c_false)
    THEN
      res_fun := pkg_gate.SetStatusProcessError(p_type);
      IF (res_fun = Utils_tmp.c_false)
      THEN
        RAISE proc_error_status;
      END IF;
      RETURN;
    END IF;
  
    --      EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess('||p_type||'): закончили успешно',pkg_gate.event_error);
  
    res_fun := pkg_gate.SetStatusProcessComplite(p_type);
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RAISE proc_error_status;
    END IF;
  
  EXCEPTION
    WHEN proc_tree_err THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess(' || p_type ||
                                      '): ошибка при запуске процесса родителя '
                                     ,pkg_gate.event_error);
    WHEN proc_err THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess(' || p_type ||
                                      '): процесс уже стартовал '
                                     ,pkg_gate.event_error);
    WHEN proc_error_status THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess(' || p_type ||
                                      '): ошибка при назначении нового статуса '
                                     ,pkg_gate.event_error);
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
  END StartProcess;

  FUNCTION GetPack(p_type IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_package(pp_type IN NUMBER) IS
      SELECT * FROM GATE_OBJ_TYPE g WHERE g.GATE_OBJ_TYPE_ID = pp_type;
    rec_package cur_package%ROWTYPE;
  
    res VARCHAR2(32) := 'none';
  BEGIN
    OPEN cur_package(p_type);
    FETCH cur_package
      INTO rec_package;
    IF (cur_package%FOUND)
    THEN
      res := rec_package.NAME_PACKAGE;
    END IF;
    CLOSE cur_package;
    RETURN res;
  END GetPack;

  FUNCTION HaveDataExport(p_number_package NUMBER) RETURN NUMBER IS
    CURSOR cur_gate_obj_s(pc_number_package NUMBER) IS
      SELECT * FROM GATE_OBJ_STATISTICS GOS WHERE GOS.GATE_PACKAGE_ID = pc_number_package;
  
    rec     cur_gate_obj_s%ROWTYPE;
    res_fun NUMBER;
  BEGIN
    OPEN cur_gate_obj_s(p_number_package);
    FETCH cur_gate_obj_s
      INTO rec;
  
    CASE
      WHEN cur_gate_obj_s%NOTFOUND THEN
        res_fun := Utils_tmp.c_false;
      WHEN cur_gate_obj_s%FOUND THEN
        res_fun := Utils_tmp.c_false;
      ELSE
        res_fun := Utils_tmp.c_exept;
    END CASE;
  
    CLOSE cur_gate_obj_s;
    RETURN res_fun;
  
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.HaveDataExport(' || p_number_package || '):' ||
                                      SQLERRM
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_exept;
  END HaveDataExport;

  FUNCTION DeleteGatePackageById
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    DELETE FROM gate_package g
     WHERE g.gate_package_id = p_number_package
       AND g.gate_obj_type_id = p_type;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.DeleteGatePackageById(' || p_number_package || '):' ||
                                      SQLERRM
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END DeleteGatePackageById;

  ----------------------------------------------------------
  --
  -- Функция выполняет процедуры до и после выполнения процессов
  -- Данные процедуры указываются в gate_obj_type
  -- p_type_run:
  -- EXEC_PROC_BEFORE - Запуск функции (параметр par_obj_type)
  --                    до начала работы Процесса. В случае возвращения = Utils_tmp.c_false
  --                    процесс прекращает выполнение
  -- EXEC_PROC_AFTER - Запуск функции после отработки процесса.
  --                   В случае возвращения = Utils_tmp.c_false процесс
  --                   откатывает данные
  ----------------------------------------------------------
  FUNCTION run_proc
  (
    p_type     NUMBER
   ,p_type_run VARCHAR2
  ) RETURN NUMBER IS
    var_sql_str  VARCHAR2(2024);
    var_obj_type gate_obj_type%ROWTYPE;
    var_res      NUMBER;
  BEGIN
  
    -- определим функции для запуска
    SELECT t.* INTO var_obj_type FROM gate_obj_type t WHERE t.gate_obj_type_id = p_type;
  
    IF p_type_run = 'EXEC_PROC_BEFORE'
       AND var_obj_type.exec_proc_before IS NOT NULL
    THEN
      -- выполним функцию ДО
      var_sql_str := 'begin :c := ' || RTRIM(var_obj_type.exec_proc_before, ';') || '(' || p_type ||
                     '); end;';
      EXECUTE IMMEDIATE var_sql_str
        USING OUT var_res;
    
    ELSIF p_type_run = 'EXEC_PROC_AFTER'
          AND var_obj_type.exec_proc_AFTER IS NOT NULL
    THEN
      -- выполним функцию ПОСЛЕ
      var_sql_str := 'begin :c := ' || RTRIM(var_obj_type.exec_proc_before, ';') || '(' || p_type ||
                     '; end;';
      EXECUTE IMMEDIATE var_sql_str
        INTO var_res;
    END IF;
  
    RETURN var_res;
  
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.run_proc:' || var_sql_str, pkg_gate.event_error);
      EventRet := pkg_gate.InserEvent('PKG_GATE.run_proc:' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_exept;
  END run_proc;

  -----------------------------
  -- Функция запуска процесса по группе
  -----------------------------
  FUNCTION RunProcess(p_type NUMBER) RETURN NUMBER IS
    res_procedure NUMBER := Utils_tmp.c_true;
    res_fun       NUMBER;
    status_error EXCEPTION;
    number_package NUMBER;
    is_have_data   NUMBER := Utils_tmp.c_false;
  
  BEGIN
    -------------------------------------------------------
    -- Определим статус процесса
    -------------------------------------------------------
    res_fun := pkg_gate.SetStatusProcessProcessing(p_type);
    -- если данный процесс содержит ошибку - выйдем
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RAISE status_error;
    END IF;
  
    -----------------------------------------------------
    -- В случае если для процесса определена функция которую необходимо выполнить - выполним
    -----------------------------------------------------
  
    res_fun := run_proc(p_type, 'EXEC_PROC_BEFORE');
  
    -- если функция вызвала ошибку - выйдем
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -- Создание пакета для данных
    res_fun := pkg_gate.CreatePackage(number_package, p_type);
    -- если создание пакета вызвало ошибку - выйдем
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -- схлопывание
  
    res_fun := PrepareData(p_type, number_package, is_have_data);
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -- проверка на то, есть ли данные? Если их нет, то пакет удаляем, и заканчиваем работу!
    IF (is_have_data = Utils_tmp.c_false)
    THEN
      res_fun := DeleteGatePackageById(p_type, number_package);
      IF (res_fun = Utils_tmp.c_false)
      THEN
        RETURN res_fun;
      END IF;
      --return Utils_tmp.c_true;
    END IF;
  
    -- копирование данных
    res_fun := PrepareData_process(p_type, number_package);
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    res_fun := InsertMessage_Gate(p_type, number_package);
  
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -----------------------------------------------------
    -- В случае если для процесса определена функция которую необходимо выполнить - выполним
    -----------------------------------------------------
  
    res_fun := run_proc(p_type, 'EXEC_PROC_AFTER');
  
    -- если функция вызвала ошибку - выйдем
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    RETURN Utils_tmp.c_true;
  
  EXCEPTION
    WHEN status_error THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.RunProcess(' || p_type ||
                                      '): ошибка при назначении нового статуса '
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.RunProcess(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END;

  FUNCTION PrepareData_process
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
    CURSOR cur_prepare_date(pc_type NUMBER) IS
      SELECT * FROM GATE_OBJ_PREPARE_DATA G WHERE G.GATE_OBJ_TYPE_ID = pc_type ORDER BY G.NUM_EXE ASC;
  
    res_fun   NUMBER;
    str_q     VARCHAR2(3000);
    str_q_del VARCHAR2(3000);
    sql_col   VARCHAR2(1000);
  
  BEGIN
    FOR rec IN cur_prepare_date(p_type)
    LOOP
    
      IF (rec.TYPE_proc = pdc_table)
      THEN
      
        sql_col   := pkg_gate_export.GetStrColumn(rec.EXPORT_LINE);
        str_q     := 'insert into ' || rec.EXPORT_TAB || '(' || sql_col || ',';
        str_q_del := 'insert into ' || rec.EXPORT_TAB || '(CODE,';
      
        IF (rec.TYPE_TABLE IS NULL)
        THEN
          str_q     := str_q || ' row_status,';
          str_q_del := str_q_del || ' row_status,';
        END IF;
      
        str_q     := str_q || ' gate_package_id)' || ' select ' || sql_col || ',';
        str_q_del := str_q_del || ' gate_package_id)' || ' select gos.ID as code,';
      
        IF (rec.TYPE_TABLE IS NULL)
        THEN
          str_q     := str_q || ' GOS.GATE_ROW_STATUS_ID as row_status, ';
          str_q_del := str_q_del || ' GOS.GATE_ROW_STATUS_ID as row_status, ';
        END IF;
      
        str_q := str_q || ' GOS.GATE_PACKAGE_ID from ' || rec.EXPORT_LINE || ',' ||
                 ' GATE_OBJ_STATISTICS GOS' || ' where CODE = GOS.ID ' || ' and GOS.GATE_PACKAGE_ID= ' ||
                 p_number_package;
      
        str_q_del := str_q_del || ' GOS.GATE_PACKAGE_ID from ' || ' GATE_OBJ_STATISTICS GOS' ||
                     ' where GOS.GATE_ROW_STATUS_ID = 2 ' || ' and GOS.GATE_PACKAGE_ID= ' ||
                     p_number_package;
      
        EXECUTE IMMEDIATE str_q;
      
        EXECUTE IMMEDIATE str_q_del;
      
      END IF;
    
      IF (rec.TYPE_proc = pdc_package)
      THEN
        EXECUTE IMMEDIATE 'BEGIN :res:=' || GetPack(p_type) || '.PrepareData_process(); END;'
          USING OUT res_fun;
        /*-- удалим обработанный пакет
        res_fun := DeleteGatePackageById(p_type,
                                       p_number_package);
        if (res_fun = Utils_tmp.c_false) then
          return res_fun;
        end if;*/
      
      END IF;
    END LOOP;
  
    RETURN Utils_tmp.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData_process(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
      EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData_process(' || p_type || '): SQL - ' ||
                                      str_q
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
    
  END PrepareData_process;

  FUNCTION DeleteMessage_Gate(id_pac IN NUMBER) RETURN NUMBER IS
  BEGIN
    DELETE FROM GATE_MESSAGE WHERE GATE_MESSAGE_ID = id_pac;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.DeleteMessage_Gate: ' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END DeleteMessage_Gate;

  FUNCTION InsertMessage_Gate
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    INSERT INTO GATE_MESSAGE
      (GATE_MESSAGE_ID, MESS_TYPE, PACK_ID)
    VALUES
      (SQ_GATE_MESSAGE.nextval, p_type, p_number_package);
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.InsertMessage_Gate: ' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
    
  END InsertMessage_Gate;

  FUNCTION Finishing
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
    res_fun NUMBER;
    status_error EXCEPTION;
  BEGIN
    res_fun := pkg_gate.SetStatusProcessFinishing(p_type);
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RAISE status_error;
    END IF;
  
    res_fun := pkg_gate.HistoryPackage(p_number_package, 'PKG_GATE_OT_Contact');
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN Utils_tmp.c_false;
    END IF;
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.Finishing: ' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END;
  -----------------------------------
  -- Подгатавливает данные в регистре измененных объектов (gate_obj)
  -- Производит схлопывание, преобразование данных, удаление лишней информации
  -- Удаление лишней информации:
  --   Если данная запись не удовлетворяет бизнес требованию, то она удаляется.
  --   Например, если Бизнес объект - Агентский договор, при изменении Контрагента, который не указан на
  --   АД. то такая запись удаляется.
  -- Преобразование данных осущестялется после удаления лишней информации
  -- Процесс заключается в подмене ID на требуемый идентификатор.
  -- Схлопывание, предназначено для минимизации передаваемой информации,
  -- например, если было зафиксировано два изменения - будет выслан один пакет
  -- с измененными данными.
  -----------------------------------
  FUNCTION PrepareData
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
   ,is_have_data     IN OUT NUMBER
  ) RETURN NUMBER IS
    var_count NUMBER;
    CURSOR cur_process
    (
      pc_number_package NUMBER
     ,p_type            NUMBER
    ) IS
      SELECT *
        FROM vgo_gate_obj_formula_b
       WHERE gate_obj_type_id = p_type
         AND gate_package_id = pc_number_package
       ORDER BY ID ASC
               ,gate_obj_id;
  
    rec_process cur_process%ROWTYPE;
    row_status  NUMBER;
    str_sql     VARCHAR2(4000);
    i           NUMBER;
  
    -- маркирует данные, которые будут дальше обрабатываться
    FUNCTION mark_data
    (
      pp_type           NUMBER
     ,pp_number_package IN NUMBER
    ) RETURN NUMBER IS
    
      CURSOR cur_ent_tab(pc_type NUMBER) IS
        SELECT *
          FROM gate_ent_table ge
         WHERE ge.gate_obj_type_id = pc_type
           AND ge.id_calc IS NOT NULL;
    
      FUNCTION mark_data_by_package
      (
        ppp_type           NUMBER
       ,ppp_number_package IN NUMBER
      ) RETURN NUMBER IS
      BEGIN
        UPDATE gate_obj g
           SET g.gate_package_id = ppp_number_package
         WHERE g.gate_obj_type_id = ppp_type
           AND g.GATE_PACKAGE_ID IS NULL;
        RETURN Utils_tmp.c_true;
      EXCEPTION
        WHEN OTHERS THEN
          EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData.mark_data.mark_data_by_package: ' ||
                                          SQLERRM
                                         ,pkg_gate.event_error);
          RETURN Utils_tmp.c_false;
      END mark_data_by_package;
    
      -- функции коректировки данных
      FUNCTION correct_data_by_package
      (
        ppp_type           NUMBER
       ,ppp_number_package IN NUMBER
      ) RETURN NUMBER IS
        CURSOR cur_ent_tab2(pc_type NUMBER) IS
          SELECT *
            FROM gate_ent_table ge
           WHERE ge.gate_obj_type_id = pc_type
             AND ge.REAL_VAL IS NOT NULL;
      
        sql_str VARCHAR2(2048);
      BEGIN
        FOR rec IN cur_ent_tab2(ppp_type)
        LOOP
          -- не пойдет обновление. ибо у нас может обновиться объект,
          -- который влияет на несколько подчиненных объектов!
          -- следаем финт.
          -- врменени нет!!! не сделал )))
        
          sql_str := 'UPDATE gate_obj GG
                    SET GG.ID = (SELECT REAL_CODE
                                   FROM (' || rec.REAL_VAL || ') B
                                  WHERE GG.ID = b.COMPARE_CODE)
                  WHERE exists (SELECT *
                                  FROM (' || rec.REAL_VAL || ') B
                                 WHERE b.COMPARE_CODE = GG.ID
                                   AND gg.gate_package_id = ' ||
                     ppp_number_package || '
                                   AND gg.gate_obj_type_id = ' || ppp_type || '
                                   AND gg.ent_id = ' || rec.ENT_ID || ')';
        
          EXECUTE IMMEDIATE sql_str;
        
        END LOOP;
        RETURN Utils_tmp.c_true;
      EXCEPTION
        WHEN OTHERS THEN
          EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData.correct_data_by_package: ' || sql_str
                                         ,pkg_gate.event_error
                                         ,ppp_type);
          EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData.correct_data_by_package: ' || SQLERRM
                                         ,pkg_gate.event_error
                                         ,ppp_type);
          RETURN Utils_tmp.c_false;
      END correct_data_by_package;
    
    BEGIN
    
      IF (mark_data_by_package(pp_type, pp_number_package) = Utils_tmp.c_false)
      THEN
        RETURN Utils_tmp.c_false;
      END IF;
    
      str_sql := ' delete from gate_obj g ' || ' WHERE g.gate_obj_type_id = ' || pp_type ||
                 ' and g.gate_package_id = ' || pp_number_package || ' and g.gate_row_status_id <> ' ||
                 row_delete || ' and not ( EXISTS ( ' || ' SELECT 1 ' || ' FROM gate_ent_table get ' ||
                 ' WHERE get.gate_obj_type_id = g.gate_obj_type_id ' || ' AND get.id_calc IS NULL ' ||
                 ' AND get.ent_id = g.ent_id) ';
    
      FOR rec IN cur_ent_tab(pp_type)
      LOOP
        str_sql := str_sql || ' or exists ( select 1 from  ( ' || rec.ID_CALC || ' ) B ' ||
                   ' where B.code_val = g.ID and g.ENT_ID = ' || rec.ENT_ID ||
                   ' and g.gate_obj_type_id = ' || pp_type || ')';
      END LOOP;
    
      str_sql := str_sql || ' ) ';
    
      EXECUTE IMMEDIATE str_sql;
      -----------------
      -- Корректировка перенесена после удаление "лишней" информации, т.к.
      -- подмена актуальна, только если данный объект принадлежит выгружаемому объекту
      -----------------
      IF (correct_data_by_package(pp_type, pp_number_package) = Utils_tmp.c_false)
      THEN
        RETURN Utils_tmp.c_false;
      END IF;
    
      RETURN Utils_tmp.c_true;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData.' || 'mark_data: ' || str_sql
                                       ,pkg_gate.event_error);
        EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData.' || 'mark_data: ' || SQLERRM
                                       ,pkg_gate.event_error);
        RETURN Utils_tmp.c_false;
    END mark_data;
  
  BEGIN
    pkg_gate.ResFun := mark_data(p_type, p_number_package);
  
    IF (pkg_gate.ResFun = Utils_tmp.c_false)
    THEN
      RETURN Utils_tmp.c_false;
    END IF;
    SELECT COUNT(*)
      INTO var_count
      FROM gate_obj o
     WHERE o.gate_package_id = p_number_package
       AND o.gate_obj_type_id = p_type;
  
    --  EventRet := pkg_gate.InserEvent('test:'||p_number_package||'#'||p_type||'count'||var_count,0);
  
    FOR rec_process IN cur_process(p_number_package, p_type)
    LOOP
    
      -- если было одно состояние
      IF (rec_process.C_N = 1)
      THEN
        row_status := rec_process.GATE_ROW_STATUS_ID;
      END IF;
      -- если было два состояния
      IF (rec_process.C_N = 2)
      THEN
        -- если это первая строка
        IF (rec_process.NN = 1)
        THEN
          row_status := rec_process.gate_row_status_id;
        END IF;
      
        -- если это вторая строка
        IF (rec_process.NN = 2)
        THEN
        
          -- если последний статус равен уделанию, то удаляем
          IF (rec_process.gate_row_status_id = pkg_gate.row_delete)
          THEN
            -- если первый статус не был вставкой
            IF (row_status != pkg_gate.row_insert)
            THEN
              row_status := pkg_gate.row_delete;
            ELSE
            
              -- если же был то ничего не делаем с записью
              row_status := pkg_gate.row_none;
            END IF;
          END IF;
        
          -- если последний статус равен изменению, а первый вставки, то вставляем
          IF (rec_process.gate_row_status_id = pkg_gate.row_update AND
             row_status = pkg_gate.row_insert)
          THEN
            row_status := pkg_gate.row_insert;
            -- иначе это обновление
          ELSIF (rec_process.gate_row_status_id = pkg_gate.row_update AND
                row_status = pkg_gate.row_update)
          THEN
            row_status := pkg_gate.row_update;
          END IF;
        END IF;
      END IF;
    
      IF (row_status != pkg_gate.row_none AND ((rec_process.NN = 2 AND rec_process.C_N = 2) OR
         (rec_process.NN = 1 AND rec_process.C_N = 1)))
      THEN
      
        INSERT INTO GATE_OBJ_STATISTICS
          (GATE_ROW_STATUS_ID, ID, GATE_PACKAGE_ID, GATE_OBJ_TYPE_ID)
        VALUES
          (row_status, rec_process.ID, p_number_package, rec_process.GATE_OBJ_TYPE_ID);
      
        is_have_data := Utils_tmp.c_true;
      END IF;
    END LOOP;
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.PrepareData: ' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END PrepareData;

  FUNCTION SynchronizeGate RETURN NUMBER
  /*данная функция на первый взгляд может показаться кривой и медленной, но она
    написана специально так, что бы при отлкючиии MSSQL GATE не отсыхал*/
   IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR cur_syn_type IS
      SELECT * FROM gate_obj_type;
  
    rec_count NUMBER := 0;
  BEGIN
    FOR rec_syn_type IN cur_syn_type
    LOOP
      EXECUTE IMMEDIATE 'begin select COUNT(*) into :val1 from gate_obj_type@gatebi G where G.gate_obj_type_id = :val2; end;'
        USING OUT rec_count, IN rec_syn_type.GATE_OBJ_TYPE_ID;
    
      IF (rec_count = 0)
      THEN
        EXECUTE IMMEDIATE ' INSERT INTO gate_obj_type@gatebi (GATE_OBJ_TYPE_ID,PARENT_ID,DESCR) ' ||
                          ' values (:val1, :val2, :val3)'
          USING IN rec_syn_type.GATE_OBJ_TYPE_ID, IN rec_syn_type.PARENT_ID, IN To_CHAR(rec_syn_type.DESCR);
      END IF;
    END LOOP;
    COMMIT;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      EventRet := pkg_gate.InserEvent('PKG_GATE.SynchronizeGate:' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END SynchronizeGate;

  FUNCTION GetDocumentTempl
  (
    p_doc_templ NUMBER
   ,p_ret_val   OUT DOC_TEMPL%ROWTYPE
  ) RETURN NUMBER IS
    CURSOR cur_doc_templ(pc_doc_templ NUMBER) IS
      SELECT * FROM DOC_TEMPL D WHERE D.DOC_TEMPL_ID = pc_doc_templ;
  
    ex_notfound EXCEPTION;
  BEGIN
    OPEN cur_doc_templ(p_doc_templ);
    FETCH cur_doc_templ
      INTO p_ret_val;
  
    IF (cur_doc_templ%NOTFOUND)
    THEN
      RAISE ex_notfound;
    END IF;
  
    CLOSE cur_doc_templ;
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN ex_notfound THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.GetDocumentTempl: не найден тип документа'
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.GetDocumentTempl:' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END;

  FUNCTION GetDocTemplByDocId
  (
    p_doc_id  NUMBER
   ,p_ret_val OUT DOC_TEMPL%ROWTYPE
  ) RETURN NUMBER IS
    CURSOR cur_doc(pc_doc_id NUMBER) IS
      SELECT DT.*
        FROM DOC_TEMPL DT
            ,DOCUMENT  D
       WHERE d.DOC_TEMPL_ID = DT.DOC_TEMPL_ID
         AND D.DOCUMENT_ID = pc_doc_id;
  
    ex_notfound EXCEPTION;
  
  BEGIN
    OPEN cur_doc(p_doc_id);
    FETCH cur_doc
      INTO p_ret_val;
  
    IF (cur_doc%NOTFOUND)
    THEN
      CLOSE cur_doc;
      RAISE ex_notfound;
    END IF;
  
    CLOSE cur_doc;
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN ex_notfound THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.GetDocTemplByDocId: документ не найден'
                                     ,pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.GetDocTemplByDocId:' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_false;
  END GetDocTemplByDocId;

  PROCEDURE CreateNewEnt
  (
    p_type_name   VARCHAR2
   ,p_type        NUMBER
   ,p_parent_type NUMBER
  ) IS
  BEGIN
    INSERT INTO GATE_OBJ_TYPE
      (GATE_OBJ_TYPE_ID, PARENT_ID, DESCR)
    VALUES
      (p_type, p_parent_type, p_type_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.CreateNewEnt:' || SQLERRM, pkg_gate.event_error);
  END CreateNewEnt;

  PROCEDURE AddExportLine
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_num_exe     NUMBER
  ) IS
  BEGIN
    INSERT INTO GATE_OBJ_EXPORT_LINE
      (GATE_OBJ_TYPE_ID, EXPORT_LINE, NUM_EXE)
    VALUES
      (p_type, p_export_line, p_num_exe);
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.AddExportLine:' || SQLERRM, pkg_gate.event_error);
  END AddExportLine;

  PROCEDURE AddPrepareData
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_tab_name    VARCHAR2
   ,p_num_exe     NUMBER
  ) IS
  BEGIN
    INSERT INTO GATE_OBJ_PREPARE_DATA
      (GATE_OBJ_TYPE_ID, EXPORT_LINE, NUM_EXE, EXPORT_TAB, TYPE_PROC)
    VALUES
      (p_type, p_export_line, p_num_exe, p_tab_name, 0);
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.AddPrepareData:' || SQLERRM, pkg_gate.event_error);
  END AddPrepareData;

  PROCEDURE AddProcessGate
  (
    p_type   NUMBER
   ,p_proc   VARCHAR2
   ,p_period VARCHAR2
  ) IS
  BEGIN
    INSERT INTO PROCESS_GATE
      (GATE_OBJ_TYPE_ID, PROC, LAST_DATE, PERIOD)
    VALUES
      (p_type, p_proc, SYSDATE, p_period);
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.AddProcessGate:' || SQLERRM, pkg_gate.event_error);
  END AddProcessGate;

  FUNCTION ExportAllObjects(p_type NUMBER) RETURN NUMBER IS
    CURSOR cur_data(c_type NUMBER) IS
      SELECT * FROM GATE_OBJ_PREPARE_DATA G WHERE G.GATE_OBJ_TYPE_ID = c_type ORDER BY g.NUM_EXE ASC;
  
    p_pack  NUMBER;
    res     NUMBER;
    sql_col VARCHAR2(1024);
    sql_str VARCHAR2(2024);
  BEGIN
  
    res := pkg_gate.CreatePackage(p_pack, p_type);
    IF (res <> Utils_tmp.c_true)
    THEN
      RETURN res;
    END IF;
  
    FOR rec IN cur_data(p_type)
    LOOP
    
      sql_col := pkg_gate_export.GetStrColumn(rec.export_line);
      sql_str := ' insert into ' || rec.export_tab || ' (' || sql_col ||
                 ',ROW_STATUS,GATE_PACKAGE_ID)' || ' select ' || sql_col || ' , 0, ' || p_pack ||
                 ' from ' || rec.export_line;
    
      EXECUTE IMMEDIATE sql_str;
    
    END LOOP;
  
    res := pkg_gate.SetPackageStatus(p_pack, pkg_gate.pkg_state_loading);
    IF (res <> Utils_tmp.c_true)
    THEN
      RETURN res;
    END IF;
  
    res := InsertMessage_Gate(p_type, p_pack);
    IF (res <> Utils_tmp.c_true)
    THEN
      RETURN res;
    END IF;
  
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.ExportAllObjects:' || sql_str, pkg_gate.event_error);
      EventRet := pkg_gate.InserEvent('PKG_GATE.ExportAllObjects:' || SQLERRM, pkg_gate.event_error);
      RETURN Utils_tmp.c_exept;
  END ExportAllObjects;

  --2009.04.14  А. Герасимов процедуры копирования ППВХ
  PROCEDURE xx_gap_copy
  (
    p_row_status     IN NUMBER
   ,p_tab_for_insert IN VARCHAR2
   ,p_code           IN NUMBER
  ) IS
    sql_txt VARCHAR2(1000);
  BEGIN
    BEGIN
      UPDATE insi.xx_gap xx SET xx.row_status = p_row_status WHERE xx.code = p_code;
    EXCEPTION
      WHEN OTHERS THEN
        --RAISE_APPLICATION_ERROR(-20666, 'ОШИБКА ОБНОВЛЕНИЯ!'||SQLERRM);
        INSERT INTO insi.ven_xx_gap_process_log VALUES (p_code, NULL, -8, SYSDATE, NULL);
    END;
    sql_txt := 'INSERT INTO ' || p_tab_for_insert || ' (SELECT * FROM insi.xx_gap xx WHERE xx.code = ' ||
               p_code || ')';
    BEGIN
      EXECUTE IMMEDIATE sql_txt;
    EXCEPTION
      WHEN OTHERS THEN
        --RAISE_APPLICATION_ERROR(-20777, 'ОШИБКА ВСТАВКИ!'||SQLERRM);
        INSERT INTO insi.ven_xx_gap_process_log VALUES (p_code, NULL, -9, SYSDATE, NULL);
    END;
    BEGIN
      DELETE FROM insi.xx_gap xx WHERE xx.code = p_code;
    EXCEPTION
      WHEN OTHERS THEN
        --RAISE_APPLICATION_ERROR(-20888, 'ОШИБКА УДАЛЕНИЯ!'||SQLERRM);
        INSERT INTO insi.ven_xx_gap_process_log VALUES (p_code, NULL, -10, SYSDATE, NULL);
    END;
    COMMIT;
  END xx_gap_copy;

  PROCEDURE xx_gap_copy_main AS
    v_doc_id       NUMBER;
    v_xx_gap       insi.xx_gap%ROWTYPE;
    v_fund_id      NUMBER;
    v_bank_acc_id  NUMBER;
    v_payer_acc_id NUMBER;
    v_gross        NUMBER;
    v_contact_id   NUMBER;
    v_cn_imp_error NUMBER;
    CURSOR c_xx_gap IS(
      SELECT * FROM insi.xx_gap);
    CURSOR c_payment(v_code NUMBER) IS(
      SELECT ap.payment_id FROM ins.ac_payment ap WHERE ap.doc_txt = v_code);
    v_payment c_payment%ROWTYPE;
  BEGIN
    SELECT cn.contact_id
      INTO v_cn_imp_error
      FROM ins.contact cn
     WHERE cn.obj_name_orig = 'Возможна ошибка импорта';
    FOR v_xx_gap IN c_xx_gap
    LOOP
      EXIT WHEN c_xx_gap%NOTFOUND;
      --по умолчанию вставляем ИД контакта "Платеж" для поля "Плательщик/получатель" в Борлас в окне "Банковские документы"
      v_contact_id := 256445;
      --выбираем количество строк. находящихся в текущий момент в таблице xx_gate - столько раз быдет выполняться внутренний цикл
      OPEN c_payment(v_xx_gap.code);
      FETCH c_payment
        INTO v_payment;
      --проверяем наличие платежа, ранее импортированного в Борлас из Навижн
      --если все нормально (ранее импортиорванных таких же данных не обнаружено)
      IF c_payment%NOTFOUND
      THEN
        SELECT MAX(f.fund_id) INTO v_fund_id FROM ins.fund f WHERE f.brief = v_xx_gap.pp_fund;
        SELECT MAX(ccba.id)
          INTO v_bank_acc_id
          FROM ins.cn_contact_bank_acc ccba
         WHERE ccba.account_nr = v_xx_gap.receiver_account;
        SELECT MAX(ccba.id)
          INTO v_payer_acc_id
          FROM ins.cn_contact_bank_acc ccba
         WHERE ccba.account_nr = v_xx_gap.payer_account;
        SELECT ins.sq_document.NEXTVAL INTO v_doc_id FROM DUAL;
        --производим пересчет NET в GROSS в зависимости от банка, определяемого по его БИК
        CASE NVL(v_xx_gap.payer_bank_bic, 'NULL')
          WHEN '044583151' --ЗАО "БАНК РУССКИЙ СТАНДАРТ"
           THEN
            BEGIN
              IF regexp_instr(UPPER(v_xx_gap.pp_note), 'MASTER') +
                 regexp_instr(UPPER(v_xx_gap.pp_note), 'VISA') +
                 regexp_instr(UPPER(v_xx_gap.pp_note), 'MASTERCARD') +
                 regexp_instr(UPPER(v_xx_gap.pp_note), 'MC') <> 0
              THEN
                v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.016);
                v_contact_id := 647739;
              ELSIF regexp_instr(UPPER(v_xx_gap.pp_note), 'AMEX') <> 0
              THEN
                v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.035);
                v_contact_id := 647739;
              ELSE
                v_gross      := v_xx_gap.pp_rev_amount;
                v_contact_id := v_cn_imp_error;
              END IF;
            END;
          WHEN '044525716' --ЗАО ВТБ 24
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 647734;
          WHEN '044552272' --МОСКОВСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
          --2009.04.29 - изменение в расчете по заявке 20486
          --2009.06.22 - изменение в расчете по заявке 26380
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
          WHEN '047888704' --ЯРОСЛАВСКИЙ          ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
          WHEN '049401726' --УДМУРТСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
          WHEN '047308896' --УЛЬЯНОВСКИЙ          ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
          WHEN '047501985' --ЧЕЛЯБИНСКИЙ          ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
            --2009.06.03 - по заявке 24079 внесены изменения
          WHEN '043807722' --КУРСКИЙ              ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
            --2009.06.03 - по заявке 24079 внесены изменения
          WHEN '044030778' --СЕВЕРО-ЗАПАДНЫЙ      ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
            --2009.06.19 - по заявке 25973 внесены изменения
          WHEN '045279836' --ОМСКИЙ РЕГИОНАЛЬНЫЙ  ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
            --2009.06.03 - по заявке 24079 внесены изменения
          WHEN '046126799' --РЯЗАНСКИЙ            ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
          WHEN '040349553' --КУБАНСКИЙ            ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.015);
            v_contact_id := 670535;
          WHEN '046577903' --ЕКАТЕРИНБУРГСКИЙ     ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
          WHEN '043601795' --САМАРСКИЙ            ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
          WHEN '046015239' --РОСТОВСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.014);
            v_contact_id := 670535;
            --2009.06.10 - по заявке 24734 внесены изменения
          WHEN '045744874' --ПРИКАМСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
            --2009.06.09 - по заявке 24613 внесены изменения
          WHEN '042202747' --НИЖЕГОРОДСКИЙ        ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
            --2009.06.03 - по заявке 24079 внесены изменения
          WHEN '044206709' --ЛИПЕЦКИЙ             ФИЛИАЛ ОАО АКБ "РОСБАНК"
           THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := 670535;
          WHEN 'NULL' THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := v_cn_imp_error;
          ELSE
            v_gross := v_xx_gap.pp_rev_amount;
        END CASE;
        --простановка контактов для банков, с которыми у нас нет договора
        IF INSTR(UPPER(REPLACE(v_xx_gap.receiver_bank_name, ' ', '')), 'РУССЛАВБАНК') <> 0
        THEN
          v_contact_id := 263453;
        ELSIF INSTR(UPPER(REPLACE(v_xx_gap.payer_bank_name, ' ', '')), 'АЛЬФА-БАНК') <> 0
        THEN
          v_contact_id := 647711;
        ELSIF UPPER(INSTR(v_xx_gap.receiver_bank_name, 'ВТБ 24')) <> 0
        THEN
          v_contact_id := 647734;
        END IF;
        --блок вставки данных. если завершается неуспешно, то обрабатываемая строка помещается в таблицу BAD
        BEGIN
          --создаем платежный документ
          BEGIN
            COMMIT;
            INSERT INTO ins.ven_ac_payment
              (rev_rate --1
              ,collection_metod_id --2
              ,payment_terms_id --3
              ,contact_id --4
              ,fund_id --5
              ,grace_date --6 дата
              ,payment_number --7
              ,num --8
              ,doc_templ_id --9
              ,note --10
              ,reg_date --11 дата
              ,payment_id --12
              ,payment_type_id --13
              ,payment_direct_id --14
              ,due_date --15 дата
              ,amount --16
              ,rev_fund_id --17
              ,payment_templ_id --18
              ,company_bank_acc_id --19
              ,contact_bank_acc_id --20
              ,rev_amount --21
              ,doc_txt) --22
            VALUES
              (1 --1 Курс приведения
              ,2 --2 Безналичный расчет
              ,78 --3 Безналичная оплата
              ,v_contact_id --4
              ,v_fund_id --5
              ,v_xx_gap.pp_date --6
              ,-1 --7
              ,v_xx_gap.pp_num --8
              ,86 --9
              ,v_xx_gap.payer_name || ' ' || v_xx_gap.pp_note || ' FROM NAVISION' --10
              ,v_xx_gap.pp_date --11
              ,v_doc_id --12
              ,1 --13
              ,0 --14
              ,v_xx_gap.pp_bnr_date --15
              ,v_gross --16
              ,v_fund_id --17
              ,2 --18
              ,v_bank_acc_id --19
              ,v_payer_acc_id --20
              ,v_xx_gap.pp_rev_amount --21
              ,v_xx_gap.code); --22
          EXCEPTION
            WHEN OTHERS THEN
              --RAISE_APPLICATION_ERROR(-20111, 'ОШИБКА ВСТАВКИ ПЛАТЕЖА!');
              ROLLBACK;
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -11, SYSDATE, NULL);
              EXIT;
          END;
          --устанавливаем ему статус "Документ добавлен"
          BEGIN
            INSERT INTO ins.ven_doc_status
              (document_id, doc_status_ref_id, start_date)
            VALUES
              (v_doc_id
              ,0 --статус документа "Документ добавлен"
              ,SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              --RAISE_APPLICATION_ERROR(-20222, 'ОШИБКА ВСТАВКИ СТАТУСА!');
              ROLLBACK;
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -12, SYSDATE, NULL);
              EXIT;
          END;
          --устанавливаем статус Новый
          BEGIN
            ins.doc.set_doc_status(v_doc_id, 'NEW', SYSDATE + 0.00002); --+10 секунд
          EXCEPTION
            WHEN OTHERS THEN
              --RAISE_APPLICATION_ERROR(-20444, 'ОШИБКА ФОРМИРОВАНИЯ СТАТУСА!'||SQLERRM);
              ROLLBACK;
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -14, SYSDATE, NULL);
              EXIT;
          END;
          --устанавливаем статус Проведен
          BEGIN
            ins.doc.set_doc_status(v_doc_id, 'TRANS', SYSDATE + 0.0008);
          EXCEPTION
            WHEN OTHERS THEN
              --RAISE_APPLICATION_ERROR(-20445, 'ОШИБКА ФОРМИРОВАНИЯ СТАТУСА!'||SQLERRM);
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -15, SYSDATE, NULL);
          END;
        
          BEGIN
            xx_gap_copy(v_doc_id, 'insi.xx_gap_good', v_xx_gap.code);
            IF v_contact_id = v_cn_imp_error
            THEN
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -18, SYSDATE, NULL);
            ELSE
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, v_doc_id, 1, SYSDATE, NULL);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              --RAISE_APPLICATION_ERROR(-20333, 'ОШИБКА КОПИРОВАНИЯ!');
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -13, SYSDATE, NULL);
          END;
        EXCEPTION
          WHEN OTHERS THEN
            xx_gap_copy(-2, 'insi.xx_gap_bad', v_xx_gap.code);
            --RAISE_APPLICATION_ERROR(-20555, 'НЕОПОЗНАННАЯ ОШИБКА!'||SQLERRM);
            INSERT INTO insi.ven_xx_gap_process_log VALUES (v_xx_gap.code, NULL, -7, SYSDATE, NULL);
        END;
      ELSE
        --такой платеж уже есть в системе
        xx_gap_copy(-1, 'insi.xx_gap_bad', v_xx_gap.code);
        INSERT INTO insi.ven_xx_gap_process_log
        VALUES
          (v_xx_gap.code, v_payment.payment_id, -6, SYSDATE, NULL);
      END IF;
      CLOSE c_payment;
      COMMIT;
    END LOOP;
  END xx_gap_copy_main;
  PROCEDURE xx_gap_main AS
  BEGIN
    xx_gap_copy_main;
  END xx_gap_main;

  --процедура привязки входящих платежей к договорам страхования
  PROCEDURE xx_gap_process AS
    CURSOR c_payments IS(
      SELECT UPPER(translate(d.note, 'x ,.', 'x')) AS note
            ,d.document_id
            ,ap.amount
            ,ap.doc_txt code
            ,ap.due_date
        FROM ins.document            d
            ,ins.ac_payment          ap
            ,insi.xx_gap_process_log gpl
            ,insi.xx_gap_status_ref  gsr
       WHERE d.document_id = ap.payment_id
         AND ap.doc_txt IS NOT NULL
         AND gpl.code = ap.doc_txt
         AND gpl.status_id = gsr.status_id
         AND gsr.status_type = 0
         AND NOT EXISTS
       (SELECT 1 FROM ins.doc_set_off dso WHERE dso.child_doc_id = ap.payment_id));
    CURSOR c_policy(p_polnum VARCHAR2) IS(
      SELECT DISTINCT pp.pol_header_id phid
                     ,pp.pol_num       pol_num
                      --именительный падеж
                     ,UPPER(REPLACE(cn.obj_name_orig, ' ', '')) i_name
                     ,UPPER(SUBSTR(cn.obj_name_orig, 1, REGEXP_INSTR(cn.obj_name_orig, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.obj_name_orig, REGEXP_INSTR(cn.obj_name_orig, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.obj_name_orig, REGEXP_INSTR(cn.obj_name_orig, ' ', 1, 2) + 1, 1)) i_name_s
                      --родительный падеж
                     ,UPPER(REPLACE(cn.genitive, ' ', '')) i_name_gen
                     ,UPPER(SUBSTR(cn.genitive, 1, REGEXP_INSTR(cn.genitive, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.genitive, REGEXP_INSTR(cn.genitive, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.genitive, REGEXP_INSTR(cn.genitive, ' ', 1, 2) + 1, 1)) i_name_s_gen
                      --винительный падеж
                     ,UPPER(REPLACE(cn.accusative, ' ', '')) i_name_acc
                     ,UPPER(SUBSTR(cn.accusative, 1, REGEXP_INSTR(cn.accusative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.accusative, REGEXP_INSTR(cn.accusative, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.accusative, REGEXP_INSTR(cn.accusative, ' ', 1, 2) + 1, 1)) i_name_s_acc
                      --дательный падеж
                     ,UPPER(REPLACE(cn.dative, ' ', '')) i_name_dat
                     ,UPPER(SUBSTR(cn.dative, 1, REGEXP_INSTR(cn.dative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.dative, REGEXP_INSTR(cn.dative, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.dative, REGEXP_INSTR(cn.dative, ' ', 1, 2) + 1, 1)) i_name_s_dat
                      --творительный падеж
                     ,UPPER(REPLACE(cn.instrumental, ' ', '')) i_name_ins
                     ,UPPER(SUBSTR(cn.instrumental, 1, REGEXP_INSTR(cn.instrumental, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.instrumental, REGEXP_INSTR(cn.instrumental, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.instrumental, REGEXP_INSTR(cn.instrumental, ' ', 1, 2) + 1, 1)) i_name_s_ins
                      --далее идет все по застрахованному
                      --именительный падеж Застр
                     ,UPPER(REPLACE(cn_ins.obj_name_orig, ' ', '')) i_name_z
                     ,UPPER(SUBSTR(cn_ins.obj_name_orig
                                  ,1
                                  ,REGEXP_INSTR(cn_ins.obj_name_orig, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.obj_name_orig
                                  ,REGEXP_INSTR(cn_ins.obj_name_orig, ' ', 1, 1) + 1
                                  ,1) || SUBSTR(cn_ins.obj_name_orig
                                               ,REGEXP_INSTR(cn_ins.obj_name_orig, ' ', 1, 2) + 1
                                               ,1)) i_name_s_z
                      --родительный падеж
                     ,UPPER(REPLACE(cn_ins.genitive, ' ', '')) i_name_gen_z
                     ,UPPER(SUBSTR(cn_ins.genitive, 1, REGEXP_INSTR(cn_ins.genitive, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.genitive, REGEXP_INSTR(cn_ins.genitive, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn_ins.genitive, REGEXP_INSTR(cn_ins.genitive, ' ', 1, 2) + 1, 1)) i_name_s_gen_z
                      --винительный падеж
                     ,UPPER(REPLACE(cn_ins.accusative, ' ', '')) i_name_acc_z
                     ,UPPER(SUBSTR(cn_ins.accusative
                                  ,1
                                  ,REGEXP_INSTR(cn_ins.accusative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.accusative
                                  ,REGEXP_INSTR(cn_ins.accusative, ' ', 1, 1) + 1
                                  ,1) || SUBSTR(cn_ins.accusative
                                               ,REGEXP_INSTR(cn_ins.accusative, ' ', 1, 2) + 1
                                               ,1)) i_name_s_acc_z
                      --дательный падеж
                     ,UPPER(REPLACE(cn_ins.dative, ' ', '')) i_name_dat_z
                     ,UPPER(SUBSTR(cn_ins.dative, 1, REGEXP_INSTR(cn_ins.dative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.dative, REGEXP_INSTR(cn_ins.dative, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn_ins.dative, REGEXP_INSTR(cn_ins.dative, ' ', 1, 2) + 1, 1)) i_name_s_dat_z
                      --творительный падеж
                     ,UPPER(REPLACE(cn_ins.instrumental, ' ', '')) i_name_ins_z
                     ,UPPER(SUBSTR(cn_ins.instrumental
                                  ,1
                                  ,REGEXP_INSTR(cn_ins.instrumental, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.instrumental
                                  ,REGEXP_INSTR(cn_ins.instrumental, ' ', 1, 1) + 1
                                  ,1) || SUBSTR(cn_ins.instrumental
                                               ,REGEXP_INSTR(cn_ins.instrumental, ' ', 1, 2) + 1
                                               ,1)) i_name_s_ins_z
        FROM ins.p_policy     pp
            ,ins.contact      cn
            ,ins.contact      cn_ins
            ,ins.p_pol_header ph
       WHERE ins.pkg_policy.get_policy_contact(pp.policy_id, 'Страхователь') = cn.contact_id(+)
         AND ins.pkg_policy.get_policy_contact(pp.policy_id, 'Застрахованное лицо') =
             cn_ins.contact_id(+)
         AND (pp.pol_num LIKE '%' || p_polnum OR pp.Notice_Num LIKE '%' || p_polnum)
         AND ph.policy_header_id = pp.pol_header_id
         AND ins.doc.get_doc_status_id(ph.policy_id) NOT IN
             (SELECT dsr.doc_status_ref_id
                FROM ins.doc_status_ref dsr
               WHERE dsr.brief IN ('READY_TO_CANCEL', 'BREAK', 'CANCEL', 'ANNULATED')));
    --все элементы план-графика выбранного полиса (по policy_id)
    CURSOR c_epg(p_phid NUMBER) IS(
      SELECT *
        FROM (SELECT ap.amount
                    ,ap.payment_id
                    ,pp.pol_num
                    ,pp.start_date
                    ,ap.plan_date
                    ,ins.pkg_payment.get_set_off_amount(ap.payment_id, pp.pol_header_id, NULL) part_pay_amount
                    ,ROW_NUMBER() OVER(PARTITION BY pp.policy_id ORDER BY ap.plan_date ASC) rnum
                    ,pp.policy_id
                FROM ins.p_policy   pp
                    ,ins.doc_doc    dd
                    ,ins.ac_payment ap
               WHERE pp.policy_id = dd.parent_id
                 AND dd.child_id = ap.payment_id
                 AND ins.doc.get_doc_status_id(ap.payment_id, SYSDATE) = 22 --"к оплате"
                 AND ap.payment_templ_id = 1 --Счет на оплату взносов
                 AND pp.pol_header_id = p_phid)
       WHERE rnum <= 2);
    --курсор, который находит все записи из таблицы логов с таким же document_id - чтобы его обновить, а не писать новую строку
    CURSOR c_gpl(p_code NUMBER) IS(
      SELECT gpl.id
        FROM insi.xx_gap_process_log gpl
            ,insi.xx_gap_status_ref  gsr
       WHERE gpl.status_id <> 0 --чтоб не выбрал привязанные платежи
         AND gpl.status_id = gsr.status_id
         AND gsr.status_type = 1 --только логи привязки
         AND gpl.code = p_code);
    v_found        VARCHAR2(20);
    v_fnd_5        NUMBER;
    v_pn_pos       NUMBER;
    tupo_counter   NUMBER := 0;
    v_epg          c_epg%ROWTYPE;
    v_status       NUMBER;
    v_status_min   NUMBER;
    v_policy       c_policy%ROWTYPE;
    v_dso_id       NUMBER;
    v_gpl          c_gpl%ROWTYPE;
    v_error_level  NUMBER := 0;
    v_note_cur_pos NUMBER;
    v_c_0          NUMBER := 0;
    v_c_1          NUMBER := 0;
    v_c_2          NUMBER := 0;
    v_c_4          NUMBER := 0;
    v_c_5          NUMBER := 0;
    v_c_19         NUMBER := 0;
  BEGIN
    --самый внешний цикл - по найденным импортированным, но еще нераспознанным платежам
    FOR v_payments IN c_payments
    LOOP
      v_found        := NULL;
      v_fnd_5        := 1;
      v_pn_pos       := 1;
      tupo_counter   := tupo_counter + 1;
      v_status_min   := 10000;
      v_status       := 10000;
      v_note_cur_pos := 1;
      LOOP
        v_fnd_5 := regexp_instr(v_payments.note, '[[:digit:]]{5}', v_note_cur_pos, v_pn_pos);
        --если нашли 5 цифр подряд
        IF v_fnd_5 <> 0
        THEN
          v_note_cur_pos := v_fnd_5 + 1;
          v_found        := regexp_substr(v_payments.note, '[[:digit:]]{5}', v_fnd_5, v_pn_pos);
          OPEN c_policy(v_found);
          FETCH c_policy
            INTO v_policy;
          --если вдруг в системе не нашлось вообще ни одного полиса с таким номером или заявлением
          IF c_policy%NOTFOUND
          THEN
            v_fnd_5  := v_fnd_5 + 1;
            v_status := -2;
            IF v_status_min > v_status
            THEN
              v_status_min := v_status;
            END IF;
          ELSE
            --если полисы с таким номером нашлись - то ищем в строке note имя страхователя в различных комбинациях
            v_fnd_5 := v_fnd_5 + 1;
            LOOP
              --цикл по найденным полисам
              IF instr(v_payments.note, v_policy.i_name) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s) <> 0
                 OR instr(v_payments.note, v_policy.i_name_gen) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_gen) <> 0
                 OR instr(v_payments.note, v_policy.i_name_acc) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_acc) <> 0
                 OR instr(v_payments.note, v_policy.i_name_dat) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_dat) <> 0
                 OR instr(v_payments.note, v_policy.i_name_ins) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_ins) <> 0
                 OR instr(v_payments.note, v_policy.i_name_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_gen_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_gen_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_acc_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_acc_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_dat_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_dat_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_ins_z) <> 0
                 OR instr(v_payments.note, v_policy.i_name_s_ins_z) <> 0
              THEN
                --тут мы должны сравнить суммы
                OPEN c_epg(v_policy.phid);
                FETCH c_epg
                  INTO v_epg;
                IF c_epg%NOTFOUND
                THEN
                  v_status := -4;
                  IF v_status_min > v_status
                  THEN
                    v_status_min := v_status;
                  END IF;
                ELSE
                  LOOP
                    --цикл по элементам план-графика полиса
                    --если сумма сошлась - можно привязывать
                    BEGIN
                      IF abs((v_epg.amount - v_epg.part_pay_amount - v_payments.amount) /
                             (v_payments.amount)) <= 0.001
                      THEN
                        IF (v_epg.amount - v_epg.part_pay_amount >= v_payments.amount)
                        THEN
                          dbms_output.put_line(tupo_counter || '|||' || v_payments.document_id ||
                                               '|||' || v_epg.payment_id || '|||' || v_policy.pol_num ||
                                               '|||' || v_policy.i_name || '|||' || v_payments.amount ||
                                               '|||' || v_epg.amount || '|||' || v_epg.plan_date ||
                                               '|||' || ' - УРА! - можно привязывать');
                          --создаем документ зачета
                          BEGIN
                            SELECT ins.sq_doc_set_off.nextval INTO v_dso_id FROM dual;
                            --фиксируем состояние на случай отката
                            <<old_commit>>
                          --COMMIT;
                            INSERT INTO ins.ven_doc_set_off vdso
                              (doc_set_off_id
                              ,doc_templ_id
                              ,note
                              ,reg_date
                              ,child_doc_id
                              ,parent_doc_id
                              ,set_off_amount
                              ,set_off_child_amount
                              ,set_off_child_fund_id
                              ,set_off_date
                              ,set_off_fund_id
                              ,set_off_rate)
                            VALUES
                              (v_dso_id
                              ,89
                              ,'документ зачета, созданный для автопривязки входящих платежных поручений, импортированных из NAVISION'
                              ,SYSDATE
                              ,v_payments.document_id
                              ,v_epg.payment_id
                              ,v_payments.amount
                              ,v_payments.amount
                              ,122
                              ,SYSDATE
                              ,122
                              ,1);
                          EXCEPTION
                            WHEN OTHERS THEN
                              v_error_level := -1;
                              GOTO label;
                          END;
                          BEGIN
                            INSERT INTO ins.ven_doc_status
                              (document_id, doc_status_ref_id, start_date)
                            VALUES
                              (v_dso_id
                              ,0 --статус документа "Документ добавлен"
                              ,SYSDATE);
                          EXCEPTION
                            WHEN OTHERS THEN
                              v_error_level := -2;
                              GOTO label;
                          END;
                          --меняем ему статус на "Новый" - при этом он зачитывается
                          BEGIN
                            ins.doc.set_doc_status(v_dso_id, 'NEW', v_payments.due_date);
                          EXCEPTION
                            WHEN OTHERS THEN
                              v_error_level := -3;
                              dbms_output.put_line(tupo_counter || '|||' ||
                                                   'Ошибка выполнения зачета в процедуре xx_gap_process ' ||
                                                   v_dso_id || ' ' || SQLERRM);
                              GOTO label;
                          END;
                          --обработка ошибок вставки и привязках
                          <<label>>
                          IF v_error_level = 0
                          THEN
                            v_status_min := 0;
                          ELSE
                            v_status_min  := -17;
                            v_error_level := 0;
                            ROLLBACK TO old_commit;
                          END IF;
                        ELSE
                          v_status := -19;
                          IF v_status_min > v_status
                          THEN
                            v_status_min := v_status;
                          END IF;
                        END IF;
                      ELSE
                        v_status := -5;
                        IF v_status_min > v_status
                        THEN
                          v_status_min := v_status;
                        END IF;
                      END IF;
                    EXCEPTION
                      WHEN zero_divide THEN
                        NULL;
                    END;
                    FETCH c_epg
                      INTO v_epg;
                    EXIT WHEN c_epg%NOTFOUND OR v_status_min = 0;
                  END LOOP; --цикл по элементам план-графика полиса
                END IF;
                CLOSE c_epg;
              ELSE
                v_status := -3;
                IF v_status_min > v_status
                THEN
                  v_status_min := v_status;
                END IF;
              END IF;
              FETCH c_policy
                INTO v_policy;
              EXIT WHEN c_policy%NOTFOUND OR v_status_min = 0;
            END LOOP; --цикл по найденным полисам
          END IF;
          CLOSE c_policy;
        ELSE
          v_status := -1;
          IF v_status_min > v_status
          THEN
            v_status_min := v_status;
          END IF;
          EXIT; --выходим из цикла, т.к. в строке нету ни одного шестизначного числа
        END IF;
        EXIT WHEN v_status_min = 0;
      END LOOP; --цикл по pp_note
      --вставка данных в лог
      OPEN c_gpl(v_payments.code);
      FETCH c_gpl
        INTO v_gpl;
      IF c_gpl%NOTFOUND
      THEN
        INSERT INTO insi.ven_xx_gap_process_log xx
        VALUES
          (v_payments.code, v_dso_id, v_status_min, SYSDATE, NULL);
      ELSE
        UPDATE insi.xx_gap_process_log gpl
           SET gpl.document_id = v_dso_id
              ,gpl.status_id   = v_status_min
              ,gpl.status_date = SYSDATE
         WHERE gpl.id = v_gpl.id;
      END IF;
      CLOSE c_gpl;
      v_dso_id := NULL;
      --COMMIT;
      CASE v_status
        WHEN 0 THEN
          v_c_0 := v_c_0 + 1;
        WHEN -1 THEN
          v_c_1 := v_c_1 + 1;
        WHEN -2 THEN
          v_c_2 := v_c_2 + 1;
        WHEN -4 THEN
          v_c_4 := v_c_4 + 1;
        WHEN -5 THEN
          v_c_5 := v_c_5 + 1;
        WHEN -19 THEN
          v_c_19 := v_c_19 + 1;
        ELSE
          NULL;
      END CASE;
    END LOOP;
    DBMS_OUTPUT.put_line('v_c_0 - ' || v_c_0);
    DBMS_OUTPUT.put_line('v_c_1 - ' || v_c_1);
    DBMS_OUTPUT.put_line('v_c_2 - ' || v_c_2);
    DBMS_OUTPUT.put_line('v_c_4 - ' || v_c_4);
    DBMS_OUTPUT.put_line('v_c_5 - ' || v_c_5);
    DBMS_OUTPUT.put_line('v_c_19 - ' || v_c_19);
  END xx_gap_process;

  --процедура привязки входящих платежей к договорам страхования

  PROCEDURE xx_gap_process_new AS
    CURSOR c_payments IS(
      SELECT UPPER(TRANSLATE(d.note, 'x ,.', 'x')) AS note
            ,d.document_id
            ,ap.amount
            ,ap.doc_txt code
            ,ap.due_date
        FROM ins.document            d
            ,ins.ac_payment          ap
            ,insi.xx_gap_process_log gpl
            ,insi.xx_gap_status_ref  gsr
       WHERE d.document_id = ap.payment_id
         AND ap.doc_txt IS NOT NULL
         AND gpl.code = ap.doc_txt
         AND gpl.status_id = gsr.status_id
         AND gsr.status_type = 0
         AND NOT EXISTS (SELECT 1 FROM ins.doc_set_off dso WHERE dso.child_doc_id = ap.payment_id)
         AND rownum < 10
      
       );
  
    CURSOR c_policy(p_polnum VARCHAR2) IS(
      SELECT DISTINCT pp.pol_header_id phid
                     ,pp.pol_num       pol_num
                      --именительный падеж
                     ,UPPER(REPLACE(cn.obj_name_orig, ' ', '')) i_name
                     ,UPPER(SUBSTR(cn.obj_name_orig, 1, REGEXP_INSTR(cn.obj_name_orig, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.obj_name_orig, REGEXP_INSTR(cn.obj_name_orig, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.obj_name_orig, REGEXP_INSTR(cn.obj_name_orig, ' ', 1, 2) + 1, 1)) i_name_s
                      --родительный падеж
                     ,UPPER(REPLACE(cn.genitive, ' ', '')) i_name_gen
                     ,UPPER(SUBSTR(cn.genitive, 1, REGEXP_INSTR(cn.genitive, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.genitive, REGEXP_INSTR(cn.genitive, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.genitive, REGEXP_INSTR(cn.genitive, ' ', 1, 2) + 1, 1)) i_name_s_gen
                      --винительный падеж
                     ,UPPER(REPLACE(cn.accusative, ' ', '')) i_name_acc
                     ,UPPER(SUBSTR(cn.accusative, 1, REGEXP_INSTR(cn.accusative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.accusative, REGEXP_INSTR(cn.accusative, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.accusative, REGEXP_INSTR(cn.accusative, ' ', 1, 2) + 1, 1)) i_name_s_acc
                      --дательный падеж
                     ,UPPER(REPLACE(cn.dative, ' ', '')) i_name_dat
                     ,UPPER(SUBSTR(cn.dative, 1, REGEXP_INSTR(cn.dative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.dative, REGEXP_INSTR(cn.dative, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.dative, REGEXP_INSTR(cn.dative, ' ', 1, 2) + 1, 1)) i_name_s_dat
                      --творительный падеж
                     ,UPPER(REPLACE(cn.instrumental, ' ', '')) i_name_ins
                     ,UPPER(SUBSTR(cn.instrumental, 1, REGEXP_INSTR(cn.instrumental, ' ', 1, 1) - 1) ||
                            SUBSTR(cn.instrumental, REGEXP_INSTR(cn.instrumental, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn.instrumental, REGEXP_INSTR(cn.instrumental, ' ', 1, 2) + 1, 1)) i_name_s_ins
                      --далее идет все по застрахованному
                      --именительный падеж Застр
                     ,UPPER(REPLACE(cn_ins.obj_name_orig, ' ', '')) i_name_z
                     ,UPPER(SUBSTR(cn_ins.obj_name_orig
                                  ,1
                                  ,REGEXP_INSTR(cn_ins.obj_name_orig, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.obj_name_orig
                                  ,REGEXP_INSTR(cn_ins.obj_name_orig, ' ', 1, 1) + 1
                                  ,1) || SUBSTR(cn_ins.obj_name_orig
                                               ,REGEXP_INSTR(cn_ins.obj_name_orig, ' ', 1, 2) + 1
                                               ,1)) i_name_s_z
                      --родительный падеж
                     ,UPPER(REPLACE(cn_ins.genitive, ' ', '')) i_name_gen_z
                     ,UPPER(SUBSTR(cn_ins.genitive, 1, REGEXP_INSTR(cn_ins.genitive, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.genitive, REGEXP_INSTR(cn_ins.genitive, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn_ins.genitive, REGEXP_INSTR(cn_ins.genitive, ' ', 1, 2) + 1, 1)) i_name_s_gen_z
                      --винительный падеж
                     ,UPPER(REPLACE(cn_ins.accusative, ' ', '')) i_name_acc_z
                     ,UPPER(SUBSTR(cn_ins.accusative
                                  ,1
                                  ,REGEXP_INSTR(cn_ins.accusative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.accusative
                                  ,REGEXP_INSTR(cn_ins.accusative, ' ', 1, 1) + 1
                                  ,1) || SUBSTR(cn_ins.accusative
                                               ,REGEXP_INSTR(cn_ins.accusative, ' ', 1, 2) + 1
                                               ,1)) i_name_s_acc_z
                      --дательный падеж
                     ,UPPER(REPLACE(cn_ins.dative, ' ', '')) i_name_dat_z
                     ,UPPER(SUBSTR(cn_ins.dative, 1, REGEXP_INSTR(cn_ins.dative, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.dative, REGEXP_INSTR(cn_ins.dative, ' ', 1, 1) + 1, 1) ||
                            SUBSTR(cn_ins.dative, REGEXP_INSTR(cn_ins.dative, ' ', 1, 2) + 1, 1)) i_name_s_dat_z
                      --творительный падеж
                     ,UPPER(REPLACE(cn_ins.instrumental, ' ', '')) i_name_ins_z
                     ,UPPER(SUBSTR(cn_ins.instrumental
                                  ,1
                                  ,REGEXP_INSTR(cn_ins.instrumental, ' ', 1, 1) - 1) ||
                            SUBSTR(cn_ins.instrumental
                                  ,REGEXP_INSTR(cn_ins.instrumental, ' ', 1, 1) + 1
                                  ,1) || SUBSTR(cn_ins.instrumental
                                               ,REGEXP_INSTR(cn_ins.instrumental, ' ', 1, 2) + 1
                                               ,1)) i_name_s_ins_z
      
        FROM ins.p_policy     pp
            ,ins.contact      cn
            ,ins.contact      cn_ins
            ,ins.p_pol_header ph
      --FROM            ins.p_policy pp, ins.p_pol_header ph
       WHERE ins.pkg_policy.get_policy_contact(pp.policy_id, 'Страхователь') = cn.contact_id(+)
         AND ins.pkg_policy.get_policy_contact(pp.policy_id, 'Застрахованное лицо') =
             cn_ins.contact_id(+)
         AND (pp.pol_num LIKE '%' || p_polnum OR pp.Notice_Num LIKE '%' || p_polnum)
         AND ph.policy_header_id = pp.pol_header_id
         AND ins.doc.get_doc_status_id(ph.policy_id) NOT IN
             (SELECT dsr.doc_status_ref_id
                FROM ins.doc_status_ref dsr
               WHERE dsr.brief IN ('READY_TO_CANCEL', 'BREAK', 'CANCEL', 'ANNULATED')));
  
    --все элементы план-графика выбранного полиса (по policy_id)
    CURSOR c_epg(p_phid NUMBER) IS(
      SELECT *
        FROM (SELECT ap.amount
                    ,ap.payment_id
                    ,pp.pol_num
                    ,pp.start_date
                    ,ap.plan_date
                    ,ins.pkg_payment.get_set_off_amount(ap.payment_id, pp.pol_header_id, NULL) part_pay_amount
                    ,ROW_NUMBER() OVER(PARTITION BY pp.policy_id ORDER BY ap.plan_date ASC) rnum
                    ,pp.policy_id
                FROM ins.p_policy   pp
                    ,ins.doc_doc    dd
                    ,ins.ac_payment ap
               WHERE pp.policy_id = dd.parent_id
                 AND dd.child_id = ap.payment_id
                 AND ins.doc.get_doc_status_id(ap.payment_id, SYSDATE) = 22 --"к оплате"
                 AND ap.payment_templ_id = 1 --Счет на оплату взносов
                 AND pp.pol_header_id = p_phid)
       WHERE rnum <= 2);
  
    --курсор, который находит все записи из таблицы логов с таким же document_id - чтобы его обновить, а не писать новую строку
    CURSOR c_gpl(p_code NUMBER) IS(
      SELECT gpl.ID
        FROM insi.xx_gap_process_log gpl
            ,insi.xx_gap_status_ref  gsr
       WHERE gpl.status_id <> 0 --чтоб не выбрал привязанные платежи
         AND gpl.status_id = gsr.status_id
         AND gsr.status_type = 1 --только логи привязки
         AND gpl.code = p_code);
  
    v_found VARCHAR2(20);
    --   v_fnd_5          NUMBER;
    v_pn_pos       NUMBER;
    tupo_counter   NUMBER := 0;
    v_epg          c_epg%ROWTYPE;
    v_status       NUMBER;
    v_status_min   NUMBER;
    v_policy       c_policy%ROWTYPE;
    v_dso_id       NUMBER;
    v_gpl          c_gpl%ROWTYPE;
    v_error_level  NUMBER := 0;
    v_note_cur_pos NUMBER;
  
    --Функция разбора строки
    --возвращает наибольший номер в строке похожий на номер полиса
    FUNCTION extract_num(p_str VARCHAR2) RETURN VARCHAR2 IS
      v_res VARCHAR2(20);
      v_pos NUMBER;
    BEGIN
      FOR i IN REVERSE 1 .. 10
      LOOP
        v_pos := regexp_instr(p_str, '[^[:digit:]][[:digit:]]{' || i || '}([^[:digit:]]|$)', 1, 1);
      
        IF v_pos > 0
        THEN
          CASE i
            WHEN 10 THEN
              v_res := SUBSTR(p_str, v_pos + 1, i);
              EXIT;
            WHEN 9 THEN
              v_res := SUBSTR(p_str, v_pos + 1, i);
              EXIT;
            WHEN 6 THEN
              v_res := SUBSTR(p_str, v_pos + 1, i);
              EXIT;
            WHEN 5 THEN
              v_res := '0' || SUBSTR(p_str, v_pos + 1, i);
              EXIT;
            WHEN 4 THEN
              v_res := '00' || SUBSTR(p_str, v_pos + 1, i);
              EXIT;
            ELSE
              NULL;
          END CASE;
        END IF;
      END LOOP;
    
      RETURN v_res;
    END extract_num;
  BEGIN
    --самый внешний цикл - по найденным импортированным, но еще нераспознанным платежам
    FOR v_payments IN c_payments
    LOOP
      v_found := NULL;
      --v_fnd_5 := 1;
      v_pn_pos       := 1;
      tupo_counter   := tupo_counter + 1;
      v_status_min   := 10000;
      v_status       := 10000;
      v_note_cur_pos := 1;
    
      LOOP
        --         v_fnd_5 := regexp_instr(v_payments.note, '[[:digit:]]{5}', v_note_cur_pos, v_pn_pos);
        v_found := extract_num(v_payments.note);
      
        --если нашли подходящее число
        --IF v_fnd_5 <> 0 THEN
        IF length(v_found) > 5
        THEN
          --v_note_cur_pos := v_fnd_5 + 1;
          --v_found := regexp_substr(v_payments.note, '[[:digit:]]{5}', v_fnd_5, v_pn_pos);
          OPEN c_policy(v_found);
        
          FETCH c_policy
            INTO v_policy;
        
          --если вдруг в системе не нашлось вообще ни одного полиса с таким номером или заявлением
          IF c_policy%NOTFOUND
          THEN
            --v_fnd_5 := v_fnd_5 + 1;
            v_status := -2;
          
            IF v_status_min > v_status
            THEN
              v_status_min := v_status;
            END IF;
          ELSE
            --если полисы с таким номером нашлись - то ищем в строке note имя страхователя в различных комбинациях
            --v_fnd_5 := v_fnd_5 + 1;
            LOOP
              --цикл по найденным полисам
              /*                  IF    INSTR(v_payments.note, v_policy.i_name) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_gen) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_gen) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_acc) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_acc) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_dat) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_dat) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_ins) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_ins) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_gen_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_gen_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_acc_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_acc_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_dat_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_dat_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_ins_z) <> 0
              OR INSTR(v_payments.note, v_policy.i_name_s_ins_z) <> 0 THEN*/ --тут мы должны сравнить суммы
              OPEN c_epg(v_policy.phid);
            
              FETCH c_epg
                INTO v_epg;
            
              IF c_epg%NOTFOUND
              THEN
                v_status := -4;
              
                IF v_status_min > v_status
                THEN
                  v_status_min := v_status;
                END IF;
              ELSE
                LOOP
                  --цикл по элементам план-графика полиса
                  --если сумма сошлась - можно привязывать
                  BEGIN
                    IF ABS((v_epg.amount - v_epg.part_pay_amount - v_payments.amount) /
                           (v_payments.amount)) <= 0.001
                    THEN
                      IF (v_epg.amount - v_epg.part_pay_amount >= v_payments.amount)
                      THEN
                        DBMS_OUTPUT.put_line(tupo_counter || '|||' || v_payments.document_id || '|||' ||
                                             v_epg.payment_id || '|||' || v_policy.pol_num || '|||'
                                             --|| v_policy.i_name
                                             || '|||' || v_payments.amount || '|||' || v_epg.amount ||
                                             '|||' || v_epg.plan_date || '|||' ||
                                             ' - УРА! - можно привязывать');
                      
                        --создаем документ зачета
                        BEGIN
                          SELECT ins.sq_doc_set_off.NEXTVAL INTO v_dso_id FROM DUAL;
                        
                          --фиксируем состояние на случай отката
                          <<old_commit>>
                        --COMMIT;
                        
                          INSERT INTO ins.ven_doc_set_off vdso
                            (doc_set_off_id
                            ,doc_templ_id
                            ,note
                            ,reg_date
                            ,child_doc_id
                            ,parent_doc_id
                            ,set_off_amount
                            ,set_off_child_amount
                            ,set_off_child_fund_id
                            ,set_off_date
                            ,set_off_fund_id
                            ,set_off_rate)
                          VALUES
                            (v_dso_id
                            ,89
                            ,'документ зачета, созданный для автопривязки входящих платежных поручений, импортированных из NAVISION'
                            ,SYSDATE
                            ,v_payments.document_id
                            ,v_epg.payment_id
                            ,v_payments.amount
                            ,v_payments.amount
                            ,122
                            ,SYSDATE
                            ,122
                            ,1);
                        EXCEPTION
                          WHEN OTHERS THEN
                            v_error_level := -1;
                            GOTO label;
                        END;
                      
                        BEGIN
                          INSERT INTO ins.ven_doc_status
                            (document_id, doc_status_ref_id, start_date)
                          VALUES
                            (v_dso_id
                            ,0 --статус документа "Документ добавлен"
                            ,SYSDATE);
                        EXCEPTION
                          WHEN OTHERS THEN
                            v_error_level := -2;
                            GOTO label;
                        END;
                      
                        --меняем ему статус на "Новый" - при этом он зачитывается
                        BEGIN
                          ins.doc.set_doc_status(v_dso_id, 'NEW', v_payments.due_date);
                        EXCEPTION
                          WHEN OTHERS THEN
                            v_error_level := -3;
                            DBMS_OUTPUT.put_line(tupo_counter || '|||' ||
                                                 'Ошибка выполнения зачета в процедуре xx_gap_process ' ||
                                                 v_dso_id || ' ' || SQLERRM);
                            GOTO label;
                        END;
                      
                        --обработка ошибок вставки и привязках
                        <<label>>
                        IF v_error_level = 0
                        THEN
                          v_status_min := 0;
                        ELSE
                          v_status_min  := -17;
                          v_error_level := 0;
                          ROLLBACK TO old_commit;
                        END IF;
                      ELSE
                        v_status := -19;
                      
                        IF v_status_min > v_status
                        THEN
                          v_status_min := v_status;
                        END IF;
                      END IF;
                    ELSE
                      v_status := -5;
                    
                      IF v_status_min > v_status
                      THEN
                        v_status_min := v_status;
                      END IF;
                    END IF;
                  EXCEPTION
                    WHEN ZERO_DIVIDE THEN
                      NULL;
                  END;
                
                  FETCH c_epg
                    INTO v_epg;
                
                  EXIT WHEN c_epg%NOTFOUND OR v_status_min = 0;
                END LOOP; --цикл по элементам план-графика полиса
              END IF;
            
              CLOSE c_epg;
            
              /*                  ELSE
                 v_status := -3;
              
                 IF v_status_min > v_status THEN
                    v_status_min := v_status;
                 END IF;
              END IF;*/
              FETCH c_policy
                INTO v_policy;
            
              EXIT WHEN c_policy%NOTFOUND OR v_status_min = 0;
            END LOOP; --цикл по найденным полисам
          END IF;
        
          CLOSE c_policy;
        ELSE
          v_status := -1;
        
          IF v_status_min > v_status
          THEN
            v_status_min := v_status;
          END IF;
        
          EXIT; --выходим из цикла, т.к. в строке нету ни одного шестизначного числа
        END IF;
      
        EXIT WHEN v_status_min = 0;
      END LOOP; --цикл по pp_note
    
      --вставка данных в лог
      OPEN c_gpl(v_payments.code);
    
      FETCH c_gpl
        INTO v_gpl;
    
      IF c_gpl%NOTFOUND
      THEN
        INSERT INTO insi.ven_xx_gap_process_log xx
        VALUES
          (v_payments.code, v_dso_id, v_status_min, SYSDATE, NULL);
      ELSE
        UPDATE insi.xx_gap_process_log gpl
           SET gpl.document_id = v_dso_id
              ,gpl.status_id   = v_status_min
              ,gpl.status_date = SYSDATE
         WHERE gpl.ID = v_gpl.ID;
      END IF;
    
      CLOSE c_gpl;
    
      v_dso_id := NULL;
      --COMMIT;
      dbms_output.put_line('v_status - ' || v_status);
    END LOOP;
  END xx_gap_process_new;
  --------------------------
END PKG_GATE_TEMP;
/

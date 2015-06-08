CREATE OR REPLACE PACKAGE INSI.pkg_gate IS
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

  eventret NUMBER;
  resfun   NUMBER;

  gate_debug NUMBER := utils_tmp.c_true;

  FUNCTION inserevent
  (
    p_mess       VARCHAR2
   ,p_type       NUMBER
   ,p_obj_type   NUMBER DEFAULT 2000
   ,p_package_id NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  PROCEDURE changerow
  (
    p_type_status NUMBER
   ,p_obj_type    NUMBER
   ,p_id          NUMBER
   ,p_ent_id      NUMBER
   ,p_tr_name     VARCHAR2 DEFAULT NULL
  );
  --  procedure SetStatusRow(p_obj_id number, p_status number);

  -- статусы процессов - возвращают Utils.c_false в случае ошибки, иначе возвращают c_true
  FUNCTION setstatusprocess
  (
    p_type_process NUMBER
   ,p_status       NUMBER
  ) RETURN NUMBER;
  FUNCTION setstatusprocessstarting(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION setstatusprocessprocessing(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION setstatusprocessfinishing(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION setstatusprocesserror(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION setstatusprocesscomplite(p_type_process NUMBER) RETURN NUMBER;
  FUNCTION setstatusprocessexport(p_type_process NUMBER) RETURN NUMBER;

  FUNCTION getstatusprocess(p_type_process NUMBER) RETURN NUMBER;

  -- управление процессами
  FUNCTION initjobs RETURN NUMBER;
  FUNCTION clearjobs RETURN NUMBER;
  FUNCTION repairjobs RETURN NUMBER;

  -- Управление пакетами на стороне BI
  FUNCTION createpackage
  (
    p_new_package OUT NUMBER
   ,p_type        IN NUMBER
  ) RETURN NUMBER;
  FUNCTION setpackagestatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER;
  FUNCTION getpackagestatus
  (
    p_pkg   NUMBER
   ,p_state OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION historypackage
  (
    p_pkg          NUMBER
   ,p_name_package VARCHAR2
  ) RETURN NUMBER;
  FUNCTION exportpackage(p_pkg NUMBER) RETURN NUMBER;
  FUNCTION importpackage(p_pkg gate_package%ROWTYPE) RETURN NUMBER;
  FUNCTION setimppackagestatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER;
  FUNCTION delimppackage(p_pkg NUMBER) RETURN NUMBER;

  -- Удаление всех пакетов, и как следствие удаление всех данных
  FUNCTION clearallpackage RETURN NUMBER;
  -- Удаление всех пакетов истории, и как следствие удаление всех данных
  FUNCTION clearallpackage_history RETURN NUMBER;
  -- Управление пакетами на стороне MSSQL
  FUNCTION setpackagestatusmssql
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER;
  -- упралвение транзакциями -- не работают!
  -- управление транзакциями осуществляется через стандратный механиз
  -- автономных транзакций в оракле.
  FUNCTION begin_trn RETURN NUMBER;
  FUNCTION commit_trn RETURN NUMBER;
  FUNCTION rollback_trn RETURN NUMBER;

  -- упраление самим гейтом
  -- Включение, выключение
  FUNCTION turn(p_on_off NUMBER) RETURN NUMBER;
  -- компиляция  -- пока пустая
  FUNCTION compilegate RETURN NUMBER;
  -- перезапуск гейта!- удаления всех данных, переинициализация всех джобов, удаление джобов
  FUNCTION reinstall RETURN NUMBER;

  -- утилитки
  -- вычисляет следущую дату через заданный интервал
  FUNCTION getnextdate(p_minuts INT) RETURN DATE;

  -- кустомицизация процессов
  PROCEDURE startprocess(p_type IN NUMBER);
  FUNCTION getpack(p_type IN NUMBER) RETURN VARCHAR2;
  FUNCTION runprocess(p_type IN NUMBER) RETURN NUMBER;
  FUNCTION preparedata
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
   ,is_have_data     IN OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION preparedata_process
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER;
  FUNCTION insertmessage_gate
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER;
  FUNCTION deletemessage_gate(id_pac IN NUMBER) RETURN NUMBER;
  FUNCTION finishing
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER;
  FUNCTION synchronizegate RETURN NUMBER;
  FUNCTION runprocessontree(p_type IN NUMBER) RETURN NUMBER;

  -- улитики
  FUNCTION getdocumenttempl
  (
    p_doc_templ NUMBER
   ,p_ret_val   OUT doc_templ%ROWTYPE
  ) RETURN NUMBER;
  FUNCTION getdoctemplbydocid
  (
    p_doc_id  NUMBER
   ,p_ret_val OUT doc_templ%ROWTYPE
  ) RETURN NUMBER;

  PROCEDURE createnewent
  (
    p_type_name   VARCHAR2
   ,p_type        NUMBER
   ,p_parent_type NUMBER
  );
  PROCEDURE addexportline
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_num_exe     NUMBER
  );
  PROCEDURE addpreparedata
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_tab_name    VARCHAR2
   ,p_num_exe     NUMBER
  );
  PROCEDURE addprocessgate
  (
    p_type   NUMBER
   ,p_proc   VARCHAR2
   ,p_period VARCHAR2
  );

  --
  FUNCTION exportallobjects(p_type NUMBER) RETURN NUMBER;
  --2009.04.14  А. Герасимов процедуры копирования ППВХ
  PROCEDURE xx_gap_copy_main;
  -- 2011.04.15, Романенков Г. Обновлённая процедура привязки платежей, работающая по справонику t_commission_rules.
  -- 2012.02.17  Байтин А. Внес коррективы.
  PROCEDURE xx_gap_copy_main_new
  (
    par_good_count  OUT NUMBER
   ,par_bad_count   OUT NUMBER
   ,par_total_count OUT NUMBER
   ,par_left_count  OUT NUMBER
  );
  --PROCEDURE xx_gap_copy(p_row_status IN NUMBER, p_tab_for_insert IN VARCHAR2, p_code IN varchar2);
  PROCEDURE xx_gap_main;
  PROCEDURE xx_gap_process;
END pkg_gate; 
/
CREATE OR REPLACE PACKAGE BODY INSI.pkg_gate IS
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

  FUNCTION inserevent
  (
    p_mess       VARCHAR2
   ,p_type       NUMBER
   ,p_obj_type   NUMBER DEFAULT 2000
   ,p_package_id NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  
    IF (p_type = event_info AND gate_debug = utils_tmp.c_false)
    THEN
      COMMIT;
      RETURN utils_tmp.c_true;
    END IF;
  
    INSERT INTO gate_event
      (gate_event_id
      ,message_event
      ,gate_event_type_id
      ,message_date
      ,gate_obj_type_id
      ,gate_package_id
      ,back_send)
    VALUES
      (sq_gate_event.nextval, p_mess, p_type, SYSDATE, p_obj_type, p_package_id, NULL);
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
      RETURN utils_tmp.c_false;
  END;

  PROCEDURE changerow
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
    IF (gate_debug = utils_tmp.c_false)
    THEN
      r_date := NULL;
    END IF;
    INSERT INTO gate_obj
      (gate_obj_id, gate_obj_type_id, id, gate_row_status_id, tr_name, row_date, ent_id)
    VALUES
      (sq_gate_obj.nextval, p_obj_type, p_id, p_type_status, p_tr_name, r_date, p_ent_id);
  EXCEPTION
    WHEN OTHERS THEN
      res := inserevent('ChangeRow - trigger (' || p_tr_name || ') : ' || SQLERRM, event_error);
  END;
  ----------------------
  -- Определяет (записывает) статус процесса.
  ----------------------
  FUNCTION setstatusprocess
  (
    p_type_process NUMBER
   ,p_status       NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR get_cur_status(pc_type_process NUMBER) IS
      SELECT * FROM process_gate_run p WHERE p.gate_obj_type_id = pc_type_process;
    get_rec_status get_cur_status%ROWTYPE;
  BEGIN
    OPEN get_cur_status(p_type_process);
    FETCH get_cur_status
      INTO get_rec_status;
  
    IF (get_cur_status%NOTFOUND)
    THEN
      INSERT INTO process_gate_run
        (gate_obj_type_id, process_gate_status, status_date)
      VALUES
        (p_type_process, p_status, SYSDATE);
    END IF;
  
    IF (get_cur_status%FOUND)
    THEN
      UPDATE process_gate_run p
         SET p.process_gate_status = p_status
            ,status_date           = SYSDATE
       WHERE p.gate_obj_type_id = p_type_process;
    END IF;
  
    CLOSE get_cur_status;
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := inserevent('SetStatusProcess:' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END setstatusprocess;

  FUNCTION setstatusprocessstarting(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN setstatusprocess(p_type_process, pgs_starting);
  END;

  FUNCTION setstatusprocessprocessing(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN setstatusprocess(p_type_process, pgs_processing);
  END;

  FUNCTION setstatusprocessfinishing(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN setstatusprocess(p_type_process, pgs_finishing);
  END;

  FUNCTION setstatusprocesserror(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN setstatusprocess(p_type_process, pgs_error);
  END;

  FUNCTION setstatusprocesscomplite(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN setstatusprocess(p_type_process, pgs_complite);
  END;

  FUNCTION setstatusprocessexport(p_type_process NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN setstatusprocess(p_type_process, pgs_complite);
  END;

  FUNCTION getstatusprocess(p_type_process NUMBER) RETURN NUMBER IS
    CURSOR get_cur_status(pc_type_process NUMBER) IS
      SELECT * FROM process_gate_run p WHERE p.gate_obj_type_id = pc_type_process;
    get_rec_status get_cur_status%ROWTYPE;
    res            NUMBER := pgs_none;
  BEGIN
    OPEN get_cur_status(p_type_process);
    FETCH get_cur_status
      INTO get_rec_status;
    IF (get_cur_status%FOUND)
    THEN
      res := get_rec_status.process_gate_status;
    END IF;
    CLOSE get_cur_status;
    RETURN res;
  END;

  FUNCTION clearjob(p_jobno NUMBER) RETURN NUMBER IS
  BEGIN
    dbms_job.remove(p_jobno);
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.ClearJob: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END clearjob;

  FUNCTION initjobs RETURN NUMBER IS
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
      SELECT * FROM process_gate_run p WHERE p.process_gate_status NOT IN (pgs_complite, pgs_error);
  
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
  
    DELETE FROM process_gate_run;
  
    FOR rec_proc IN proc_table
    LOOP
      IF (rec_proc.job_num IS NOT NULL)
      THEN
        fun_res := clearjob(rec_proc.job_num);
      END IF;
      jobno := NULL;
    
      dbms_job.submit(jobno, rec_proc.proc, getnextdate(i), rec_proc.period);
      eventret := inserevent('PKG_GATE.InitJobs: инициализирован JOB (' || jobno ||
                             ') для типа процесс (' || rec_proc.gate_obj_type_id || ')'
                            ,event_error);
      UPDATE process_gate
         SET job_num   = jobno
            ,last_date = SYSDATE
       WHERE gate_obj_type_id = rec_proc.gate_obj_type_id;
    
      i := i + 1;
    END LOOP;
  
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN proc_is_runing THEN
      eventret := inserevent('PKG_GATE.InitJobs: процессы запущены', event_error);
      RETURN utils_tmp.c_false;
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.InitJobs: ' || SQLERRM, event_error);
      ROLLBACK;
      RETURN utils_tmp.c_false;
  END initjobs;

  FUNCTION clearjobs RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR proc_table IS
      SELECT * FROM process_gate;
  BEGIN
    FOR rec_proc IN proc_table
    LOOP
      IF (rec_proc.job_num IS NOT NULL)
      THEN
        dbms_job.remove(rec_proc.job_num);
        UPDATE process_gate SET job_num = NULL WHERE gate_obj_type_id = rec_proc.gate_obj_type_id;
      END IF;
    END LOOP;
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.ClearJobs: ' || SQLERRM, event_error);
      ROLLBACK;
      RETURN utils_tmp.c_false;
  END clearjobs;

  FUNCTION repairjobs RETURN NUMBER IS
  BEGIN
    DELETE FROM process_gate_run pgr WHERE pgr.process_gate_status = pgs_error;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.RepairJobs: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END;

  -- Управление пакетами
  FUNCTION createpackage
  (
    p_new_package OUT NUMBER
   ,p_type        IN NUMBER
  ) RETURN NUMBER IS
    res_new_sq NUMBER;
  BEGIN
    SELECT sq_gate_package.nextval INTO res_new_sq FROM dual;
  
    INSERT INTO gate_package
      (gate_package_id, pack_date_create, pack_status, gate_obj_type_id)
    VALUES
      (res_new_sq, SYSDATE, pkg_state_creating, p_type);
  
    p_new_package := res_new_sq;
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := inserevent('PKG_GATE.CreatePackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END createpackage;

  FUNCTION historypackage
  (
    p_pkg          NUMBER
   ,p_name_package VARCHAR2
  ) RETURN NUMBER IS
    p_state NUMBER;
    state_invalid EXCEPTION;
    history_err   EXCEPTION;
  BEGIN
  
    -- пакет помечается как отработанный
    resfun := getpackagestatus(p_pkg, p_state);
    IF (resfun = utils_tmp.c_false)
    THEN
      RETURN utils_tmp.c_false;
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
      (id, gate_obj_type_id, gate_row_status_id, gate_package_id)
      SELECT gos.id
            ,gos.gate_obj_type_id
            ,gos.gate_row_status_id
            ,gos.gate_package_id
        FROM gate_obj_statistics gos
       WHERE gos.gate_package_id = p_pkg;
  
    resfun := setpackagestatus(p_pkg, pkg_state_comlite);
    IF (resfun = utils_tmp.c_false)
    THEN
      RETURN utils_tmp.c_false;
    END IF;
  
    -- пакет в истории помечается как отработанный
    UPDATE gate_package_history g
       SET g.pack_date_complite = SYSDATE
          ,g.pack_status        = pkg_state_comlite
     WHERE g.gate_package_id = p_pkg;
  
    -- удаляется основной пакет, по каскадным ссылкам уходят все данные автоматически
    DELETE FROM gate_package WHERE gate_package_id = p_pkg;
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN history_err THEN
      eventret := inserevent('PKG_GATE.HistoryPackage: неопределенная ошибка при запуске истории в друго пакете'
                            ,event_error);
      RETURN utils_tmp.c_false;
    WHEN state_invalid THEN
      eventret := inserevent('PKG_GATE.HistoryPackage: пакет находиться не в загруженом состоянии'
                            ,event_error);
      RETURN utils_tmp.c_false;
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.HistoryPackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END historypackage;

  FUNCTION getpackagestatus
  (
    p_pkg   NUMBER
   ,p_state OUT NUMBER
  ) RETURN NUMBER IS
    CURSOR cur_pkg IS
      SELECT * FROM gate_package WHERE gate_package_id = p_pkg;
  
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
  
    res := rec_pkg.pack_status;
  
    CLOSE cur_pkg;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.GetPackageStatus: не найден пакет', event_error);
      RETURN utils_tmp.c_false;
  END;

  FUNCTION setpackagestatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER IS
  BEGIN
    CASE p_state
      WHEN pkg_state_creating THEN
        UPDATE gate_package
           SET pack_date_create = SYSDATE
              ,pack_status      = p_state
         WHERE gate_package_id = p_pkg;
      WHEN pkg_state_loading THEN
        UPDATE gate_package
           SET pack_date_load = SYSDATE
              ,pack_status    = p_state
         WHERE gate_package_id = p_pkg;
      WHEN pkg_state_comlite THEN
        UPDATE gate_package
           SET pack_date_complite = SYSDATE
              ,pack_status        = p_state
         WHERE gate_package_id = p_pkg;
    END CASE;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.SetPackageStatus: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END;

  FUNCTION exportpackage(p_pkg NUMBER) RETURN NUMBER IS
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
  
    eventret := inserevent('PKG_GATE.ExportPackage 1 PACK_NUM = ' || p_pkg, event_info);
  
    IF (cur_package%NOTFOUND)
    THEN
      CLOSE cur_package;
      RETURN utils_tmp.c_false;
    END IF;
  
    eventret := inserevent('PKG_GATE.ExportPackage 2 PACK_NUM = ' || p_pkg, event_info);
  
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
      eventret := inserevent('PKG_GATE.ExportPackage: исправление пакета началось ' || p_pkg
                            ,event_info);
      EXECUTE IMMEDIATE 'delete from gate_package@gatebi where gate_package_id = :val1'
        USING IN p_pkg;
      eventret := inserevent('PKG_GATE.ExportPackage: исправление пакета закончилось успешно' || p_pkg
                            ,event_info);
    END IF;
  
    EXECUTE IMMEDIATE ' INSERT INTO gate_package@gatebi(gate_package_id,pack_date_create,pack_status,gate_obj_type_id) ' ||
                      ' values (:val1,:val2,:val3,:val4) '
      USING IN p_pkg, IN rec_package.pack_date_create, IN pkg_state_creating, IN rec_package.gate_obj_type_id;
  
    CLOSE cur_package;
  
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := inserevent('PKG_GATE.ExportPackage: SQL - ' || sql_str, event_error);
      eventret := inserevent('PKG_GATE.ExportPackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END;

  FUNCTION importpackage(p_pkg gate_package%ROWTYPE) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    CURSOR cur_pack_in(p_gate_package_id NUMBER) IS
      SELECT * FROM gate_in_package g WHERE g.gate_package_id = p_gate_package_id;
  
    p_d DATE := SYSDATE;
  
    rec_pack_in cur_pack_in%ROWTYPE;
  
  BEGIN
    OPEN cur_pack_in(p_pkg.gate_package_id);
    FETCH cur_pack_in
      INTO rec_pack_in;
  
    IF (cur_pack_in%FOUND)
    THEN
      -- найден пакет. проверяется его статус, если статус что загружается, то удаляем его!
      IF (rec_pack_in.pack_status = pkg_state_creating)
      THEN
        eventret := inserevent('PKG_GATE.InportPackage: Найден ошибочный пакет, пытаемся его удалить' ||
                               rec_pack_in.gate_package_id
                              ,event_info);
        DELETE FROM gate_in_package WHERE gate_package_id = rec_pack_in.gate_package_id;
        COMMIT;
        eventret := inserevent('PKG_GATE.InportPackage: Ошибочный пакет удален' ||
                               rec_pack_in.gate_package_id
                              ,event_info);
      ELSE
        eventret := inserevent('PKG_GATE.InportPackage: Пакет с таким номером, уже зарегистрирован в шлюзе.' ||
                               rec_pack_in.gate_package_id
                              ,event_error);
        CLOSE cur_pack_in;
        RETURN utils_tmp.c_false;
      END IF;
    END IF;
  
    CLOSE cur_pack_in;
  
    INSERT INTO gate_in_package
      (gate_package_id
      ,pack_date_create
      ,pack_status
      ,gate_obj_type_id
      ,pack_date_load
      ,pack_date_complite)
    VALUES
      (p_pkg.gate_package_id
      ,p_d
      ,pkg_state_creating
      ,p_pkg.gate_obj_type_id
      ,p_pkg.pack_date_load
      ,p_pkg.pack_date_complite);
  
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := inserevent('PKG_GATE.InportPackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END importpackage;

  FUNCTION delimppackage(p_pkg NUMBER) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE 'delete from GATE_IN_PACKAGE@gatebi where GATE_PACKAGE_ID = ' || p_pkg;
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := inserevent('PKG_GATE.InportPackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END delimppackage;

  FUNCTION setimppackagestatus
  (
    p_pkg   NUMBER
   ,p_state NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    CASE p_state
      WHEN pkg_state_creating THEN
        UPDATE gate_in_package
           SET pack_date_create = SYSDATE
              ,pack_status      = p_state
         WHERE gate_package_id = p_pkg;
      WHEN pkg_state_loading THEN
        UPDATE gate_in_package
           SET pack_date_load = SYSDATE
              ,pack_status    = p_state
         WHERE gate_package_id = p_pkg;
      WHEN pkg_state_comlite THEN
        UPDATE gate_in_package
           SET pack_date_complite = SYSDATE
              ,pack_status        = p_state
         WHERE gate_package_id = p_pkg;
    END CASE;
  
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := inserevent('PKG_GATE.InportPackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END setimppackagestatus;

  FUNCTION setobjstatus
  (
    p_on_off   NUMBER
   ,p_name_obj VARCHAR2
   ,p_type     VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    CASE p_type
      WHEN 'TRIGGER' THEN
        BEGIN
          IF (p_on_off = utils_tmp.c_true)
          THEN
            EXECUTE IMMEDIATE 'alter trigger ' || p_name_obj || ' enable';
          ELSE
            EXECUTE IMMEDIATE 'alter trigger ' || p_name_obj || ' disable';
          END IF;
        END;
    END CASE;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.SetObjStatus: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END setobjstatus;

  FUNCTION turn(p_on_off NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rec IN (SELECT s.object_type
                      ,s.object_name
                  FROM sys.user_objects s
                      ,gate_sys_obj     gso
                 WHERE gso.sys_obj_name = s.object_name)
    LOOP
      resfun := setobjstatus(p_on_off, rec.object_name, rec.object_type);
      IF (resfun = utils_tmp.c_false)
      THEN
        RETURN utils_tmp.c_false;
      END IF;
    END LOOP;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.Turn: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END;

  -- компиляция  -- пока пустая
  FUNCTION compilegate RETURN NUMBER IS
    CURSOR cur_prep IS
      SELECT * FROM gate_obj_prepare_data;
  
    CURSOR cur_wrap
    (
      p_tab1 VARCHAR2
     ,p_tab2 VARCHAR2
    ) IS
      SELECT b.column_name        AS b
            ,b.internal_column_id AS b1
            ,b.data_type          AS b2
            ,a.column_name        AS a
            ,a.internal_column_id AS a1
            ,a.data_type          AS a2
        FROM all_tab_cols a
            ,all_tab_cols b
       WHERE b.table_name = p_tab1
         AND a.table_name = p_tab2
         AND a.internal_column_id = b.internal_column_id
         AND a.data_type <> b.data_type;
  
  BEGIN
    FOR rec IN cur_prep
    LOOP
      FOR rec_w IN cur_wrap(rec.export_line, rec.export_tab)
      LOOP
        eventret := inserevent('Ошибка данные отличаются ' || rec.export_line || ' -> ' ||
                               rec.export_tab
                              ,event_error);
        eventret := inserevent(rec_w.b || '.' || rec_w.b1 || '.' || rec_w.b2 || ' -> ' || rec_w.a || '.' ||
                               rec_w.a1 || '.' || rec_w.a2
                              ,event_error);
      END LOOP;
    END LOOP;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.CompileGate: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END compilegate;

  FUNCTION reinstall RETURN NUMBER IS
  BEGIN
    DELETE FROM gate_package_history;
    DELETE FROM gate_package;
    DELETE FROM gate_obj;
  
    resfun := clearjobs;
    resfun := initjobs;
  
    DELETE FROM gate_event;
    eventret := inserevent('PKG_GATE.ReInstall: GATE перестартовал успешно ' || SQLERRM
                          ,event_info);
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.ReInstall: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END reinstall;

  FUNCTION begin_trn RETURN NUMBER IS
    fn_res NUMBER;
  BEGIN
    -- fn_res := DBMS_HS_PASSTHROUGH.EXECUTE_IMMEDIATE@GATEBI('begin transaction');
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.Begin_Trn: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END begin_trn;

  FUNCTION rollback_trn RETURN NUMBER IS
    fn_res NUMBER;
  BEGIN
    --fn_res := DBMS_HS_PASSTHROUGH.EXECUTE_IMMEDIATE@GATEBI('ROLLBACK');
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.Commit_Trn: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END rollback_trn;

  FUNCTION commit_trn RETURN NUMBER IS
    fn_res NUMBER;
  BEGIN
    --fn_res := DBMS_HS_PASSTHROUGH.EXECUTE_IMMEDIATE@GATEBI('COMMIT');
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.Commit_Trn: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END commit_trn;

  FUNCTION setpackagestatusmssql
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
    RETURN utils_tmp.c_true;
  END;

  FUNCTION clearallpackage RETURN NUMBER IS
  BEGIN
    DELETE FROM gate_package;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.ClearAllPackage: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END clearallpackage;

  FUNCTION clearallpackage_history RETURN NUMBER IS
  BEGIN
    DELETE FROM gate_package_history;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := inserevent('PKG_GATE.ClearAllPackage_history: ' || SQLERRM, event_error);
      RETURN utils_tmp.c_false;
  END clearallpackage_history;

  FUNCTION getnextdate(p_minuts INT) RETURN DATE IS
    res DATE;
  BEGIN
    SELECT trunc(SYSDATE) +
           (trunc(to_char(SYSDATE, 'sssss') / (p_minuts * 60)) + 1) * p_minuts / 24 / 60
      INTO res
      FROM dual;
    RETURN res;
  END getnextdate;

  FUNCTION runprocessontree(p_type IN NUMBER) RETURN NUMBER IS
    CURSOR cur_pr(pc_type NUMBER) IS
      SELECT *
        FROM gate_obj_type got
       WHERE got.gate_obj_type_id <> p_type
      CONNECT BY got.gate_obj_type_id = PRIOR got.parent_id
       START WITH got.gate_obj_type_id = pc_type;
  
    rec_pr cur_pr%ROWTYPE;
  BEGIN
    OPEN cur_pr(p_type);
    FETCH cur_pr
      INTO rec_pr;
  
    IF (cur_pr%FOUND)
    THEN
      startprocess(rec_pr.gate_obj_type_id);
    END IF;
  
    CLOSE cur_pr;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.RunProcessOnTree(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
    
  END runprocessontree;

  PROCEDURE startprocess(p_type IN NUMBER) IS
    res_s    NUMBER;
    res_proc NUMBER;
    res_fun  NUMBER;
    proc_err          EXCEPTION;
    proc_error_status EXCEPTION;
    proc_tree_err     EXCEPTION;
  BEGIN
  
    res_s := pkg_gate.getstatusprocess(p_type);
    IF (res_s = pkg_gate.pgs_none OR res_s = pkg_gate.pgs_complite)
    THEN
      res_fun := pkg_gate.setstatusprocessstarting(p_type);
    ELSE
      --raise proc_err;
      RETURN;
    END IF;
  
    res_fun := runprocessontree(p_type);
    IF (res_fun = utils_tmp.c_false)
    THEN
      RAISE proc_tree_err;
    END IF;
  
    --EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess('||p_type||'): Стартанули ',pkg_gate.event_error);
    res_proc := runprocess(p_type);
  
    IF (res_proc = utils_tmp.c_false)
    THEN
      res_fun := pkg_gate.setstatusprocesserror(p_type);
      IF (res_fun = utils_tmp.c_false)
      THEN
        RAISE proc_error_status;
      END IF;
      RETURN;
    END IF;
  
    --      EventRet := pkg_gate.InserEvent('PKG_GATE.StartProcess('||p_type||'): закончили успешно',pkg_gate.event_error);
  
    res_fun := pkg_gate.setstatusprocesscomplite(p_type);
    IF (res_fun = utils_tmp.c_false)
    THEN
      RAISE proc_error_status;
    END IF;
  
  EXCEPTION
    WHEN proc_tree_err THEN
      eventret := pkg_gate.inserevent('PKG_GATE.StartProcess(' || p_type ||
                                      '): ошибка при запуске процесса родителя '
                                     ,pkg_gate.event_error);
    WHEN proc_err THEN
      eventret := pkg_gate.inserevent('PKG_GATE.StartProcess(' || p_type ||
                                      '): процесс уже стартовал '
                                     ,pkg_gate.event_error);
    WHEN proc_error_status THEN
      eventret := pkg_gate.inserevent('PKG_GATE.StartProcess(' || p_type ||
                                      '): ошибка при назначении нового статуса '
                                     ,pkg_gate.event_error);
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.StartProcess(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
  END startprocess;

  FUNCTION getpack(p_type IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_package(pp_type IN NUMBER) IS
      SELECT * FROM gate_obj_type g WHERE g.gate_obj_type_id = pp_type;
    rec_package cur_package%ROWTYPE;
  
    res VARCHAR2(32) := 'none';
  BEGIN
    OPEN cur_package(p_type);
    FETCH cur_package
      INTO rec_package;
    IF (cur_package%FOUND)
    THEN
      res := rec_package.name_package;
    END IF;
    CLOSE cur_package;
    RETURN res;
  END getpack;

  FUNCTION havedataexport(p_number_package NUMBER) RETURN NUMBER IS
    CURSOR cur_gate_obj_s(pc_number_package NUMBER) IS
      SELECT * FROM gate_obj_statistics gos WHERE gos.gate_package_id = pc_number_package;
  
    rec     cur_gate_obj_s%ROWTYPE;
    res_fun NUMBER;
  BEGIN
    OPEN cur_gate_obj_s(p_number_package);
    FETCH cur_gate_obj_s
      INTO rec;
  
    CASE
      WHEN cur_gate_obj_s%NOTFOUND THEN
        res_fun := utils_tmp.c_false;
      WHEN cur_gate_obj_s%FOUND THEN
        res_fun := utils_tmp.c_false;
      ELSE
        res_fun := utils_tmp.c_exept;
    END CASE;
  
    CLOSE cur_gate_obj_s;
    RETURN res_fun;
  
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.HaveDataExport(' || p_number_package || '):' ||
                                      SQLERRM
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_exept;
  END havedataexport;

  FUNCTION deletegatepackagebyid
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    DELETE FROM gate_package g
     WHERE g.gate_package_id = p_number_package
       AND g.gate_obj_type_id = p_type;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.DeleteGatePackageById(' || p_number_package || '):' ||
                                      SQLERRM
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END deletegatepackagebyid;

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
      var_sql_str := 'begin :c := ' || rtrim(var_obj_type.exec_proc_before, ';') || '(' || p_type ||
                     '); end;';
      EXECUTE IMMEDIATE var_sql_str
        USING OUT var_res;
    
    ELSIF p_type_run = 'EXEC_PROC_AFTER'
          AND var_obj_type.exec_proc_after IS NOT NULL
    THEN
      -- выполним функцию ПОСЛЕ
      var_sql_str := 'begin :c := ' || rtrim(var_obj_type.exec_proc_before, ';') || '(' || p_type ||
                     '; end;';
      EXECUTE IMMEDIATE var_sql_str
        INTO var_res;
    END IF;
  
    RETURN var_res;
  
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.run_proc:' || var_sql_str, pkg_gate.event_error);
      eventret := pkg_gate.inserevent('PKG_GATE.run_proc:' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_exept;
  END run_proc;

  -----------------------------
  -- Функция запуска процесса по группе
  -----------------------------
  FUNCTION runprocess(p_type NUMBER) RETURN NUMBER IS
    res_procedure NUMBER := utils_tmp.c_true;
    res_fun       NUMBER;
    status_error EXCEPTION;
    number_package NUMBER;
    is_have_data   NUMBER := utils_tmp.c_false;
  
  BEGIN
    -------------------------------------------------------
    -- Определим статус процесса
    -------------------------------------------------------
    res_fun := pkg_gate.setstatusprocessprocessing(p_type);
    -- если данный процесс содержит ошибку - выйдем
    IF (res_fun = utils_tmp.c_false)
    THEN
      RAISE status_error;
    END IF;
  
    -----------------------------------------------------
    -- В случае если для процесса определена функция которую необходимо выполнить - выполним
    -----------------------------------------------------
  
    res_fun := run_proc(p_type, 'EXEC_PROC_BEFORE');
  
    -- если функция вызвала ошибку - выйдем
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -- Создание пакета для данных
    res_fun := pkg_gate.createpackage(number_package, p_type);
    -- если создание пакета вызвало ошибку - выйдем
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -- схлопывание
  
    res_fun := preparedata(p_type, number_package, is_have_data);
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -- проверка на то, есть ли данные? Если их нет, то пакет удаляем, и заканчиваем работу!
    IF (is_have_data = utils_tmp.c_false)
    THEN
      res_fun := deletegatepackagebyid(p_type, number_package);
      IF (res_fun = utils_tmp.c_false)
      THEN
        RETURN res_fun;
      END IF;
      --return Utils_tmp.c_true;
    END IF;
  
    -- копирование данных
    res_fun := preparedata_process(p_type, number_package);
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    res_fun := insertmessage_gate(p_type, number_package);
  
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    -----------------------------------------------------
    -- В случае если для процесса определена функция которую необходимо выполнить - выполним
    -----------------------------------------------------
  
    res_fun := run_proc(p_type, 'EXEC_PROC_AFTER');
  
    -- если функция вызвала ошибку - выйдем
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN res_fun;
    END IF;
  
    RETURN utils_tmp.c_true;
  
  EXCEPTION
    WHEN status_error THEN
      eventret := pkg_gate.inserevent('PKG_GATE.RunProcess(' || p_type ||
                                      '): ошибка при назначении нового статуса '
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.RunProcess(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END;

  FUNCTION preparedata_process
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
    CURSOR cur_prepare_date(pc_type NUMBER) IS
      SELECT * FROM gate_obj_prepare_data g WHERE g.gate_obj_type_id = pc_type ORDER BY g.num_exe ASC;
  
    res_fun   NUMBER;
    str_q     VARCHAR2(3000);
    str_q_del VARCHAR2(3000);
    sql_col   VARCHAR2(1000);
  
  BEGIN
    FOR rec IN cur_prepare_date(p_type)
    LOOP
    
      IF (rec.type_proc = pdc_table)
      THEN
      
        sql_col   := pkg_gate_export.getstrcolumn(rec.export_line);
        str_q     := 'insert into ' || rec.export_tab || '(' || sql_col || ',';
        str_q_del := 'insert into ' || rec.export_tab || '(CODE,';
      
        IF (rec.type_table IS NULL)
        THEN
          str_q     := str_q || ' row_status,';
          str_q_del := str_q_del || ' row_status,';
        END IF;
      
        str_q     := str_q || ' gate_package_id)' || ' select ' || sql_col || ',';
        str_q_del := str_q_del || ' gate_package_id)' || ' select gos.ID as code,';
      
        IF (rec.type_table IS NULL)
        THEN
          str_q     := str_q || ' GOS.GATE_ROW_STATUS_ID as row_status, ';
          str_q_del := str_q_del || ' GOS.GATE_ROW_STATUS_ID as row_status, ';
        END IF;
      
        str_q := str_q || ' GOS.GATE_PACKAGE_ID from ' || rec.export_line || ',' ||
                 ' GATE_OBJ_STATISTICS GOS' || ' where CODE = GOS.ID ' || ' and GOS.GATE_PACKAGE_ID= ' ||
                 p_number_package;
      
        str_q_del := str_q_del || ' GOS.GATE_PACKAGE_ID from ' || ' GATE_OBJ_STATISTICS GOS' ||
                     ' where GOS.GATE_ROW_STATUS_ID = 2 ' || ' and GOS.GATE_PACKAGE_ID= ' ||
                     p_number_package;
      
        EXECUTE IMMEDIATE str_q;
      
        EXECUTE IMMEDIATE str_q_del;
      
      END IF;
    
      IF (rec.type_proc = pdc_package)
      THEN
        EXECUTE IMMEDIATE 'BEGIN :res:=' || getpack(p_type) || '.PrepareData_process(); END;'
          USING OUT res_fun;
        /*-- удалим обработанный пакет
        res_fun := DeleteGatePackageById(p_type,
                                       p_number_package);
        if (res_fun = Utils_tmp.c_false) then
          return res_fun;
        end if;*/
      
      END IF;
    END LOOP;
  
    RETURN utils_tmp.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
      eventret := pkg_gate.inserevent('PKG_GATE.PrepareData_process(' || p_type || '):' || SQLERRM
                                     ,pkg_gate.event_error);
      eventret := pkg_gate.inserevent('PKG_GATE.PrepareData_process(' || p_type || '): SQL - ' ||
                                      str_q
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
    
  END preparedata_process;

  FUNCTION deletemessage_gate(id_pac IN NUMBER) RETURN NUMBER IS
  BEGIN
    DELETE FROM gate_message WHERE gate_message_id = id_pac;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.DeleteMessage_Gate: ' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END deletemessage_gate;

  FUNCTION insertmessage_gate
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    INSERT INTO gate_message
      (gate_message_id, mess_type, pack_id)
    VALUES
      (sq_gate_message.nextval, p_type, p_number_package);
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.InsertMessage_Gate: ' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
    
  END insertmessage_gate;

  FUNCTION finishing
  (
    p_type           IN NUMBER
   ,p_number_package IN NUMBER
  ) RETURN NUMBER IS
    res_fun NUMBER;
    status_error EXCEPTION;
  BEGIN
    res_fun := pkg_gate.setstatusprocessfinishing(p_type);
    IF (res_fun = utils_tmp.c_false)
    THEN
      RAISE status_error;
    END IF;
  
    res_fun := pkg_gate.historypackage(p_number_package, 'PKG_GATE_OT_Contact');
    IF (res_fun = utils_tmp.c_false)
    THEN
      RETURN utils_tmp.c_false;
    END IF;
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.Finishing: ' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
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
  FUNCTION preparedata
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
       ORDER BY id ASC
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
           AND g.gate_package_id IS NULL;
        RETURN utils_tmp.c_true;
      EXCEPTION
        WHEN OTHERS THEN
          eventret := pkg_gate.inserevent('PKG_GATE.PrepareData.mark_data.mark_data_by_package: ' ||
                                          SQLERRM
                                         ,pkg_gate.event_error);
          RETURN utils_tmp.c_false;
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
             AND ge.real_val IS NOT NULL;
      
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
                                   FROM (' || rec.real_val || ') B
                                  WHERE GG.ID = b.COMPARE_CODE)
                  WHERE exists (SELECT *
                                  FROM (' || rec.real_val || ') B
                                 WHERE b.COMPARE_CODE = GG.ID
                                   AND gg.gate_package_id = ' ||
                     ppp_number_package || '
                                   AND gg.gate_obj_type_id = ' || ppp_type || '
                                   AND gg.ent_id = ' || rec.ent_id || ')';
        
          EXECUTE IMMEDIATE sql_str;
        
        END LOOP;
        RETURN utils_tmp.c_true;
      EXCEPTION
        WHEN OTHERS THEN
          eventret := pkg_gate.inserevent('PKG_GATE.PrepareData.correct_data_by_package: ' || sql_str
                                         ,pkg_gate.event_error
                                         ,ppp_type);
          eventret := pkg_gate.inserevent('PKG_GATE.PrepareData.correct_data_by_package: ' || SQLERRM
                                         ,pkg_gate.event_error
                                         ,ppp_type);
          RETURN utils_tmp.c_false;
      END correct_data_by_package;
    
    BEGIN
    
      IF (mark_data_by_package(pp_type, pp_number_package) = utils_tmp.c_false)
      THEN
        RETURN utils_tmp.c_false;
      END IF;
    
      str_sql := ' delete from gate_obj g ' || ' WHERE g.gate_obj_type_id = ' || pp_type ||
                 ' and g.gate_package_id = ' || pp_number_package || ' and g.gate_row_status_id <> ' ||
                 row_delete || ' and not ( EXISTS ( ' || ' SELECT 1 ' || ' FROM gate_ent_table get ' ||
                 ' WHERE get.gate_obj_type_id = g.gate_obj_type_id ' || ' AND get.id_calc IS NULL ' ||
                 ' AND get.ent_id = g.ent_id) ';
    
      FOR rec IN cur_ent_tab(pp_type)
      LOOP
        str_sql := str_sql || ' or exists ( select 1 from  ( ' || rec.id_calc || ' ) B ' ||
                   ' where B.code_val = g.ID and g.ENT_ID = ' || rec.ent_id ||
                   ' and g.gate_obj_type_id = ' || pp_type || ')';
      END LOOP;
    
      str_sql := str_sql || ' ) ';
    
      EXECUTE IMMEDIATE str_sql;
      -----------------
      -- Корректировка перенесена после удаление "лишней" информации, т.к.
      -- подмена актуальна, только если данный объект принадлежит выгружаемому объекту
      -----------------
      IF (correct_data_by_package(pp_type, pp_number_package) = utils_tmp.c_false)
      THEN
        RETURN utils_tmp.c_false;
      END IF;
    
      RETURN utils_tmp.c_true;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        eventret := pkg_gate.inserevent('PKG_GATE.PrepareData.' || 'mark_data: ' || str_sql
                                       ,pkg_gate.event_error);
        eventret := pkg_gate.inserevent('PKG_GATE.PrepareData.' || 'mark_data: ' || SQLERRM
                                       ,pkg_gate.event_error);
        RETURN utils_tmp.c_false;
    END mark_data;
  
  BEGIN
    pkg_gate.resfun := mark_data(p_type, p_number_package);
  
    IF (pkg_gate.resfun = utils_tmp.c_false)
    THEN
      RETURN utils_tmp.c_false;
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
      IF (rec_process.c_n = 1)
      THEN
        row_status := rec_process.gate_row_status_id;
      END IF;
      -- если было два состояния
      IF (rec_process.c_n = 2)
      THEN
        -- если это первая строка
        IF (rec_process.nn = 1)
        THEN
          row_status := rec_process.gate_row_status_id;
        END IF;
      
        -- если это вторая строка
        IF (rec_process.nn = 2)
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
    
      IF (row_status != pkg_gate.row_none AND ((rec_process.nn = 2 AND rec_process.c_n = 2) OR
         (rec_process.nn = 1 AND rec_process.c_n = 1)))
      THEN
      
        INSERT INTO gate_obj_statistics
          (gate_row_status_id, id, gate_package_id, gate_obj_type_id)
        VALUES
          (row_status, rec_process.id, p_number_package, rec_process.gate_obj_type_id);
      
        is_have_data := utils_tmp.c_true;
      END IF;
    END LOOP;
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.PrepareData: ' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END preparedata;

  FUNCTION synchronizegate RETURN NUMBER
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
        USING OUT rec_count, IN rec_syn_type.gate_obj_type_id;
    
      IF (rec_count = 0)
      THEN
        EXECUTE IMMEDIATE ' INSERT INTO gate_obj_type@gatebi (GATE_OBJ_TYPE_ID,PARENT_ID,DESCR) ' ||
                          ' values (:val1, :val2, :val3)'
          USING IN rec_syn_type.gate_obj_type_id, IN rec_syn_type.parent_id, IN to_char(rec_syn_type.descr);
      END IF;
    END LOOP;
    COMMIT;
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      eventret := pkg_gate.inserevent('PKG_GATE.SynchronizeGate:' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END synchronizegate;

  FUNCTION getdocumenttempl
  (
    p_doc_templ NUMBER
   ,p_ret_val   OUT doc_templ%ROWTYPE
  ) RETURN NUMBER IS
    CURSOR cur_doc_templ(pc_doc_templ NUMBER) IS
      SELECT * FROM doc_templ d WHERE d.doc_templ_id = pc_doc_templ;
  
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
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN ex_notfound THEN
      eventret := pkg_gate.inserevent('PKG_GATE.GetDocumentTempl: не найден тип документа'
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.GetDocumentTempl:' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END;

  FUNCTION getdoctemplbydocid
  (
    p_doc_id  NUMBER
   ,p_ret_val OUT doc_templ%ROWTYPE
  ) RETURN NUMBER IS
    CURSOR cur_doc(pc_doc_id NUMBER) IS
      SELECT dt.*
        FROM doc_templ dt
            ,document  d
       WHERE d.doc_templ_id = dt.doc_templ_id
         AND d.document_id = pc_doc_id;
  
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
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN ex_notfound THEN
      eventret := pkg_gate.inserevent('PKG_GATE.GetDocTemplByDocId: документ не найден'
                                     ,pkg_gate.event_error);
      RETURN utils_tmp.c_false;
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.GetDocTemplByDocId:' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_false;
  END getdoctemplbydocid;

  PROCEDURE createnewent
  (
    p_type_name   VARCHAR2
   ,p_type        NUMBER
   ,p_parent_type NUMBER
  ) IS
  BEGIN
    INSERT INTO gate_obj_type
      (gate_obj_type_id, parent_id, descr)
    VALUES
      (p_type, p_parent_type, p_type_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.CreateNewEnt:' || SQLERRM, pkg_gate.event_error);
  END createnewent;

  PROCEDURE addexportline
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_num_exe     NUMBER
  ) IS
  BEGIN
    INSERT INTO gate_obj_export_line
      (gate_obj_type_id, export_line, num_exe)
    VALUES
      (p_type, p_export_line, p_num_exe);
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.AddExportLine:' || SQLERRM, pkg_gate.event_error);
  END addexportline;

  PROCEDURE addpreparedata
  (
    p_type        NUMBER
   ,p_export_line VARCHAR2
   ,p_tab_name    VARCHAR2
   ,p_num_exe     NUMBER
  ) IS
  BEGIN
    INSERT INTO gate_obj_prepare_data
      (gate_obj_type_id, export_line, num_exe, export_tab, type_proc)
    VALUES
      (p_type, p_export_line, p_num_exe, p_tab_name, 0);
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.AddPrepareData:' || SQLERRM, pkg_gate.event_error);
  END addpreparedata;

  PROCEDURE addprocessgate
  (
    p_type   NUMBER
   ,p_proc   VARCHAR2
   ,p_period VARCHAR2
  ) IS
  BEGIN
    INSERT INTO process_gate
      (gate_obj_type_id, proc, last_date, period)
    VALUES
      (p_type, p_proc, SYSDATE, p_period);
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.AddProcessGate:' || SQLERRM, pkg_gate.event_error);
  END addprocessgate;

  FUNCTION exportallobjects(p_type NUMBER) RETURN NUMBER IS
    CURSOR cur_data(c_type NUMBER) IS
      SELECT * FROM gate_obj_prepare_data g WHERE g.gate_obj_type_id = c_type ORDER BY g.num_exe ASC;
  
    p_pack  NUMBER;
    res     NUMBER;
    sql_col VARCHAR2(1024);
    sql_str VARCHAR2(2024);
  BEGIN
  
    res := pkg_gate.createpackage(p_pack, p_type);
    IF (res <> utils_tmp.c_true)
    THEN
      RETURN res;
    END IF;
  
    FOR rec IN cur_data(p_type)
    LOOP
    
      sql_col := pkg_gate_export.getstrcolumn(rec.export_line);
      sql_str := ' insert into ' || rec.export_tab || ' (' || sql_col ||
                 ',ROW_STATUS,GATE_PACKAGE_ID)' || ' select ' || sql_col || ' , 0, ' || p_pack ||
                 ' from ' || rec.export_line;
    
      EXECUTE IMMEDIATE sql_str;
    
    END LOOP;
  
    res := pkg_gate.setpackagestatus(p_pack, pkg_gate.pkg_state_loading);
    IF (res <> utils_tmp.c_true)
    THEN
      RETURN res;
    END IF;
  
    res := insertmessage_gate(p_type, p_pack);
    IF (res <> utils_tmp.c_true)
    THEN
      RETURN res;
    END IF;
  
    RETURN utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      eventret := pkg_gate.inserevent('PKG_GATE.ExportAllObjects:' || sql_str, pkg_gate.event_error);
      eventret := pkg_gate.inserevent('PKG_GATE.ExportAllObjects:' || SQLERRM, pkg_gate.event_error);
      RETURN utils_tmp.c_exept;
  END exportallobjects;

  /*TODO перенести в pkg_contact*/
  FUNCTION get_bank_contact_id(par_bik VARCHAR2) RETURN number IS
    v_contact_id NUMBER;
    CURSOR cur(cp_bik VARCHAR2) IS
      SELECT cci.contact_id
        FROM ins.cn_contact_ident cci
            ,ins.t_id_type        tit
            ,ins.cn_contact_role  ccr
            ,ins.t_contact_role   cr
       WHERE tit.id = cci.id_type
         AND tit.brief = 'BIK'
         AND ccr.contact_id = cci.contact_id
         AND cr.id = ccr.role_id
         AND cr.brief = 'BANK'
         AND cci.id_value = cp_bik
       ORDER BY cci.contact_id;
  
  BEGIN
    OPEN cur(par_bik);
    FETCH cur
      INTO v_contact_id;
    CLOSE cur;
  
    IF v_contact_id IS NULL
    THEN
      RETURN NULL;
    ELSE
      RETURN v_contact_id;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --2009.04.14  А. Герасимов процедуры копирования ППВХ
  PROCEDURE xx_gap_copy
  (
    p_row_status     IN NUMBER
   ,p_tab_for_insert IN VARCHAR2
   ,p_code           IN VARCHAR2
   ,par_md5          VARCHAR2
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
    sql_txt := 'INSERT INTO ' || p_tab_for_insert ||
               ' (SELECT xx.*, :par_md5 FROM insi.xx_gap xx WHERE xx.code = :p_code)';
    BEGIN
      EXECUTE IMMEDIATE sql_txt
        USING IN par_md5, p_code;
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
    v_doc_id           NUMBER;
    v_xx_gap           insi.xx_gap%ROWTYPE;
    v_fund_id          NUMBER;
    v_bank_acc_id      NUMBER;
    v_payer_acc_id     NUMBER;
    v_gross            NUMBER;
    v_contact_id       NUMBER;
    v_cn_imp_error     NUMBER;
    v_payment_terms_id NUMBER;
    CURSOR c_xx_gap IS(
      SELECT * FROM insi.xx_gap);
    CURSOR c_payment(v_code VARCHAR2) IS(
      SELECT ap.payment_id FROM ins.ac_payment ap WHERE ap.doc_txt = v_code);
    v_payment c_payment%ROWTYPE;
  BEGIN
    SELECT cn.contact_id
      INTO v_cn_imp_error
      FROM ins.contact cn
     WHERE cn.obj_name_orig = 'Возможна ошибка импорта';
  
    SELECT id INTO v_payment_terms_id FROM ins.t_payment_terms pt WHERE pt.is_default = 1;
  
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
        SELECT ins.sq_document.nextval INTO v_doc_id FROM dual;
        --производим пересчет NET в GROSS в зависимости от банка, определяемого по его БИК
        CASE nvl(v_xx_gap.payer_bank_bic, 'NULL')
          WHEN '044583151' --ЗАО "БАНК РУССКИЙ СТАНДАРТ"
           THEN
            BEGIN
              IF regexp_instr(upper(v_xx_gap.pp_note), 'MASTER') +
                 regexp_instr(upper(v_xx_gap.pp_note), 'VISA') +
                 regexp_instr(upper(v_xx_gap.pp_note), 'MASTERCARD') +
                 regexp_instr(upper(v_xx_gap.pp_note), 'MC') <> 0
              THEN
                v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.016);
                v_contact_id := 647739;
              ELSIF regexp_instr(upper(v_xx_gap.pp_note), 'AMEX') <> 0
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
            /*
            WHEN '044552272' --МОСКОВСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
            --2009.04.29 - изменение в расчете по заявке 20486
             --2009.06.22 - изменение в расчете по заявке 26380
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             WHEN '047888704' --ЯРОСЛАВСКИЙ          ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             WHEN '049401726' --УДМУРТСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             WHEN '047308896' --УЛЬЯНОВСКИЙ          ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             WHEN '047501985' --ЧЕЛЯБИНСКИЙ          ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             --2009.06.03 - по заявке 24079 внесены изменения
             WHEN '043807722' --КУРСКИЙ              ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             --2009.06.03 - по заявке 24079 внесены изменения
             WHEN '044030778' --СЕВЕРО-ЗАПАДНЫЙ      ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             --2009.06.19 - по заявке 25973 внесены изменения
             WHEN '045279836' --ОМСКИЙ РЕГИОНАЛЬНЫЙ  ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             --2009.06.03 - по заявке 24079 внесены изменения
             WHEN '046126799' --РЯЗАНСКИЙ            ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             WHEN '040349553' --КУБАНСКИЙ            ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.015);   v_contact_id := 670535;
             WHEN '046577903' --ЕКАТЕРИНБУРГСКИЙ     ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             WHEN '043601795' --САМАРСКИЙ            ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             WHEN '046015239' --РОСТОВСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount/(1-0.014);   v_contact_id := 670535;
             --2009.06.10 - по заявке 24734 внесены изменения
             WHEN '045744874' --ПРИКАМСКИЙ           ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             --2009.06.09 - по заявке 24613 внесены изменения
             WHEN '042202747' --НИЖЕГОРОДСКИЙ        ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;
             --2009.06.03 - по заявке 24079 внесены изменения
             WHEN '044206709' --ЛИПЕЦКИЙ             ФИЛИАЛ ОАО АКБ "РОСБАНК"
                 THEN v_gross := v_xx_gap.pp_rev_amount;             v_contact_id := 670535;*/
        
        --2009.09.22 - по заявке 46427 внесены изменения
          WHEN '044583119' --АКБ "Промсвязьбанк" (ЗАО)
           THEN
            v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.018);
            v_contact_id := 747429;
          WHEN '044585416' -- ЗАО «Объединенная система моментальных платежей» (QIWI). RT#110816
           THEN
            IF nvl(v_xx_gap.payer_account, '') = '40702810700000000686'
            THEN
              v_gross      := v_xx_gap.pp_rev_amount / (1 - 0.012);
              v_contact_id := 1139903;
            END IF;
          WHEN 'NULL' THEN
            v_gross      := v_xx_gap.pp_rev_amount;
            v_contact_id := v_cn_imp_error;
          ELSE
            v_gross := v_xx_gap.pp_rev_amount;
            IF v_xx_gap.payer_bank_bic IN ('044552272'
                                          ,'047888704'
                                          ,'049401726'
                                          ,'047308896'
                                          ,'047501985'
                                          ,'043807722'
                                          ,'044030778'
                                          ,'045279836'
                                          ,'046126799'
                                          ,'040349553'
                                          ,'046577903'
                                          ,'043601795'
                                          ,'046015239'
                                          ,'045744874'
                                          ,'042202747'
                                          ,'044206709')
            THEN
              v_contact_id := 670535;
            END IF;
        END CASE;
        --простановка контактов для банков, с которыми у нас нет договора
        IF instr(upper(REPLACE(v_xx_gap.receiver_bank_name, ' ', '')), 'РУССЛАВБАНК') <> 0
        THEN
          v_contact_id := 263453;
        ELSIF instr(upper(REPLACE(v_xx_gap.payer_bank_name, ' ', '')), 'АЛЬФА-БАНК') <> 0
        THEN
          v_contact_id := 647711;
        ELSIF upper(instr(v_xx_gap.receiver_bank_name, 'ВТБ 24')) <> 0
        THEN
          v_contact_id := 647734;
        END IF;
        --блок вставки данных. если завершается неуспешно, то обрабатываемая строка помещается в таблицу BAD
        BEGIN
          --создаем платежный документ
          BEGIN
            SAVEPOINT ins_payment;
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
              ,v_payment_terms_id --3
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
              dbms_output.put_line('ОШИБКА ВСТАВКИ ПЛАТЕЖА! ' || SQLERRM);
              ROLLBACK TO ins_payment;
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
              dbms_output.put_line('ОШИБКА ВСТАВКИ СТАТУСА!' || SQLERRM);
              ROLLBACK TO ins_payment;
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
              dbms_output.put_line('ОШИБКА ФОРМИРОВАНИЯ СТАТУСА! - 1 ' || SQLERRM);
              ROLLBACK TO ins_payment;
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -14, SYSDATE, NULL);
              EXIT;
          END;
          --устанавливаем статус Проведен
          BEGIN
            ins.doc.set_doc_status(v_doc_id, 'TRANS', SYSDATE + 0.0008);
            dbms_output.put_line('ОШИБКА ФОРМИРОВАНИЯ СТАТУСА! - 2 ' || SQLERRM);
          EXCEPTION
            WHEN OTHERS THEN
              --RAISE_APPLICATION_ERROR(-20445, 'ОШИБКА ФОРМИРОВАНИЯ СТАТУСА!'||SQLERRM);
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -15, SYSDATE, NULL);
          END;
        
          BEGIN
            xx_gap_copy(v_doc_id, 'insi.xx_gap_good', v_xx_gap.code, NULL);
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
              dbms_output.put_line('ОШИБКА КОПИРОВАНИЯ!');
              INSERT INTO insi.ven_xx_gap_process_log
              VALUES
                (v_xx_gap.code, NULL, -13, SYSDATE, NULL);
          END;
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('OTHERS');
            xx_gap_copy(-2, 'insi.xx_gap_bad', v_xx_gap.code, NULL);
            --RAISE_APPLICATION_ERROR(-20555, 'НЕОПОЗНАННАЯ ОШИБКА!'||SQLERRM);
            INSERT INTO insi.ven_xx_gap_process_log VALUES (v_xx_gap.code, NULL, -7, SYSDATE, NULL);
        END;
      ELSE
        --такой платеж уже есть в системе
        dbms_output.put_line('такой платеж уже есть в системе');
        xx_gap_copy(-1, 'insi.xx_gap_bad', v_xx_gap.code, NULL);
        INSERT INTO insi.ven_xx_gap_process_log
        VALUES
          (v_xx_gap.code, v_payment.payment_id, -6, SYSDATE, NULL);
      END IF;
      CLOSE c_payment;
    END LOOP;
    COMMIT;
  END xx_gap_copy_main;

 PROCEDURE xx_gap_copy_main_new
 (
   par_good_count  OUT NUMBER
  ,par_bad_count   OUT NUMBER
  ,par_total_count OUT NUMBER
  ,par_left_count  OUT NUMBER
 ) IS
   CURSOR c_payments_or
   (
     par_payer_bank_bic   ins.t_commission_rules.payer_bank_bic%TYPE
    ,par_payer_account    ins.t_commission_rules.payer_account%TYPE
    ,par_receiver_account ins.t_commission_rules.receiver_account%TYPE
    ,par_pp_note          ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note1         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note2         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note3         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note4         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note5         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note6         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note7         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note8         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note9         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note10        ins.t_commission_rules.pp_note%TYPE
   ) IS
     SELECT g.*
           ,ins.pkg_utils.get_md5_string(pp_note || to_char(pp_date, 'ddmmyyyy') || pp_num ||
                                         pp_doc_sum) AS md5
       FROM insi.xx_gap g
      WHERE 1 = 1
           -- Пустой БИК в ПП соответствует БИКу -1 в Правилах, 
           -- т.к. пустое поле в Правилах захотели использовать под "любое значение"
        AND (nvl(g.payer_bank_bic, -1) = par_payer_bank_bic OR par_payer_bank_bic IS NULL)
        AND (par_payer_account IS NULL OR g.payer_account = par_payer_account)
        AND (par_receiver_account IS NULL OR g.receiver_account = par_receiver_account)
        AND (par_pp_note IS NULL OR
            (par_pp_note IS NOT NULL AND
            ((par_pp_note1 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note1 || '%') OR
            (par_pp_note2 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note2 || '%') OR
            (par_pp_note3 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note3 || '%') OR
            (par_pp_note4 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note4 || '%') OR
            (par_pp_note5 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note5 || '%') OR
            (par_pp_note6 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note6 || '%') OR
            (par_pp_note7 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note7 || '%') OR
            (par_pp_note8 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note8 || '%') OR
            (par_pp_note9 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note9 || '%') OR
            (par_pp_note10 IS NOT NULL AND g.pp_note LIKE '%' || par_pp_note10 || '%'))));
 
   CURSOR c_payments_and
   (
     par_payer_bank_bic   ins.t_commission_rules.payer_bank_bic%TYPE
    ,par_payer_account    ins.t_commission_rules.payer_account%TYPE
    ,par_receiver_account ins.t_commission_rules.receiver_account%TYPE
    ,par_pp_note          ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note1         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note2         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note3         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note4         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note5         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note6         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note7         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note8         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note9         ins.t_commission_rules.pp_note%TYPE
    ,par_pp_note10        ins.t_commission_rules.pp_note%TYPE
   ) IS
     SELECT g.*
           ,ins.pkg_utils.get_md5_string(pp_note || to_char(pp_date, 'ddmmyyyy') || pp_num ||
                                         pp_doc_sum) AS md5
       FROM insi.xx_gap g
      WHERE 1 = 1
           -- Пустой БИК в ПП соответствует БИКу -1 в Правилах, 
           -- т.к. пустое поле в Правилах захотели использовать под "любое значение"
        AND (nvl(g.payer_bank_bic, -1) = par_payer_bank_bic OR par_payer_bank_bic IS NULL)
        AND (par_payer_account IS NULL OR g.payer_account = par_payer_account)
        AND (par_receiver_account IS NULL OR g.receiver_account = par_receiver_account)
        AND (par_pp_note IS NULL OR
             (par_pp_note IS NOT NULL AND ((g.pp_note LIKE '%' || par_pp_note1 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note2 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note3 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note4 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note5 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note6 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note7 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note8 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note9 || '%') AND
            (g.pp_note LIKE '%' || par_pp_note10 || '%'))));
 
   -- Переменные процедуры
 
   pmnts c_payments_and%ROWTYPE;
 
   v_payment          NUMBER;
   v_fund_id          NUMBER;
   v_bank_acc_id      NUMBER;
   v_payer_acc_id     NUMBER;
   v_doc_id           NUMBER;
   v_gross            NUMBER;
   v_setdate          DATE;
   v_cn_imp_error     NUMBER;
   v_payment_terms_id NUMBER;
   v_contact_id       NUMBER;
   v_contact_name     VARCHAR2(255);
   v_payer_bank_name  VARCHAR2(255);
   v_contact_bank_acc VARCHAR2(255);
   v_company_bank_acc VARCHAR2(255);
   v_payer_inn        VARCHAR2(15);
 
   -- Переменные для распарсивания назначения платежа (VISA, MASTERCARD, MC, MASTER, ...)
   --v_pp_note_cnt             NUMBER;
   v_pp_note1  VARCHAR2(150);
   v_pp_note2  VARCHAR2(150);
   v_pp_note3  VARCHAR2(150);
   v_pp_note4  VARCHAR2(150);
   v_pp_note5  VARCHAR2(150);
   v_pp_note6  VARCHAR2(150);
   v_pp_note7  VARCHAR2(150);
   v_pp_note8  VARCHAR2(150);
   v_pp_note9  VARCHAR2(150);
   v_pp_note10 VARCHAR2(150);
 
   v_date DATE := SYSDATE;
   v_set_off_state number;
  
    v_bank_contact_name VARCHAR(2000);
    v_ap_contact_id     NUMBER;
 BEGIN
   par_good_count  := 0;
   par_bad_count   := 0;
   par_total_count := 0;
 
   SELECT cn.contact_id
     INTO v_cn_imp_error
     FROM ins.contact cn
    WHERE cn.obj_name_orig = 'Возможна ошибка импорта';
   --v_cn_imp_error := 779872; -- Что б наверняка. Для EDU_TEST
 
   SELECT id INTO v_payment_terms_id FROM ins.t_payment_terms pt WHERE pt.is_default = 1;
 
   -- Пометим входящие записи, с которыми будем работать
   UPDATE insi.xx_gap SET proc_date = v_date WHERE proc_date IS NULL;
 
   -- Проверим, нет ли правил, которые уже не должны действовать.
   FOR n IN (SELECT cr.t_commission_rules_id
               FROM ins.ven_t_commission_rules cr
              WHERE SYSDATE > cr.date_end
                AND ins.doc.get_last_doc_status_brief(cr.t_commission_rules_id) = 'ACTIVE')
   LOOP
     ins.doc.set_doc_status(n.t_commission_rules_id, 'QUIT');
   END LOOP;
   COMMIT;
 
   -- Идём от созданных правил
   FOR rls IN (SELECT cr.*
                     ,pt.doc_templ_id AS main_doc_templ_id
                 FROM ins.ven_t_commission_rules cr
                 JOIN ins.ac_payment_templ pt
                   ON pt.payment_templ_id = cr.payment_templ_id
                WHERE ins.doc.get_last_doc_status_brief(cr.t_commission_rules_id) = 'ACTIVE'
                  AND SYSDATE BETWEEN cr.date_begin AND cr.date_end
                ORDER BY rule_num ASC)
   LOOP
     -- Байтин А.
     -- Каждый раз приходится блочить таблицу
     DECLARE
       TYPE t_rows IS TABLE OF NUMBER(1);
       vt_rows t_rows;
     BEGIN
       SELECT 1 BULK COLLECT INTO vt_rows FROM xx_gap FOR UPDATE NOWAIT;
     EXCEPTION
       WHEN OTHERS THEN
         RETURN;
     END;
     -- Определяем все (10) назначения платежа, разделитель - перенос строки
     --v_pp_note_cnt := LENGTH(rls.pp_note) - LENGTH(REPLACE(rls.pp_note, Chr(10)))+1;
     v_pp_note1  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 1, 'm'), chr(10));
     v_pp_note2  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 2, 'm'), chr(10));
     v_pp_note3  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 3, 'm'), chr(10));
     v_pp_note4  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 4, 'm'), chr(10));
     v_pp_note5  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 5, 'm'), chr(10));
     v_pp_note6  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 6, 'm'), chr(10));
     v_pp_note7  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 7, 'm'), chr(10));
     v_pp_note8  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 8, 'm'), chr(10));
     v_pp_note9  := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 9, 'm'), chr(10));
     v_pp_note10 := REPLACE(regexp_substr(rls.pp_note, '\w+' || chr(10) || '?', 1, 10, 'm'), chr(10));
   
     -- Идём по платежам в шлюзе, выбираем только удовлетворяющие условиям текущего правила
     IF rls.operation_type = 0
     THEN
       OPEN c_payments_or(rls.payer_bank_bic
                         ,rls.payer_account
                         ,rls.receiver_account
                         ,rls.pp_note
                         ,v_pp_note1
                         ,v_pp_note2
                         ,v_pp_note3
                         ,v_pp_note4
                         ,v_pp_note5
                         ,v_pp_note6
                         ,v_pp_note7
                         ,v_pp_note8
                         ,v_pp_note9
                         ,v_pp_note10);
     ELSE
       OPEN c_payments_and(rls.payer_bank_bic
                          ,rls.payer_account
                          ,rls.receiver_account
                          ,rls.pp_note
                          ,v_pp_note1
                          ,v_pp_note2
                          ,v_pp_note3
                          ,v_pp_note4
                          ,v_pp_note5
                          ,v_pp_note6
                          ,v_pp_note7
                          ,v_pp_note8
                          ,v_pp_note9
                          ,v_pp_note10);
     END IF;
   
     LOOP
       IF rls.operation_type = 0
       THEN
         FETCH c_payments_or
           INTO pmnts;
         EXIT WHEN c_payments_or%NOTFOUND;
       ELSE
         FETCH c_payments_and
           INTO pmnts;
         EXIT WHEN c_payments_and%NOTFOUND;
       END IF;
       par_total_count := par_total_count + 1;
       /*DBMS_OUTPUT.PUT_LINE('        payer_bank_bic: '||pmnts.payer_bank_bic);    
       DBMS_OUTPUT.PUT_LINE('        payer_account: '||pmnts.payer_account);    
       DBMS_OUTPUT.PUT_LINE('        receiver_account: '||pmnts.receiver_account);                
       DBMS_OUTPUT.PUT_LINE('        pp_note: '||pmnts.pp_note); 
       DBMS_OUTPUT.PUT_LINE('        $$$: '||pmnts.pp_rev_amount||' ==> '||pmnts.pp_rev_amount/(1 - rls.commission_rate/100));*/
       --      BEGIN
       IF rls.rule_num = 999 -- Правило по умолчанию, contact = "Платеж"
          AND pmnts.payer_bank_bic IS NOT NULL
       THEN
         /* Байтин А.
            Медленно работает
         SELECT nvl(MAX(bl.contact_id),rls.contact_id) INTO v_contact_id
         FROM ins.v_contact_bank_list bl   
         WHERE bl.bic = pmnts.payer_bank_bic;
         */
         SELECT nvl(MAX(ci.contact_id), rls.contact_id)
           INTO v_contact_id
           FROM ins.ven_cn_contact_ident ci
          WHERE ci.id_value = pmnts.payer_bank_bic
            AND ci.id_type = (SELECT id FROM ins.t_id_type WHERE brief = 'BIK');
       ELSE
         v_contact_id := rls.contact_id;
       END IF;
     
       /*Капля П.С. По просьбе Киприча всегда и для всех пишем контакт "Возможно ошибка импорта"*/
       v_contact_id       := v_cn_imp_error;
       v_contact_name     := pmnts.payer_name;
       v_payer_bank_name  := pmnts.payer_bank_name;
       v_contact_bank_acc := pmnts.payer_bank_account;
       v_company_bank_acc := pmnts.receiver_account;
       v_payer_inn        := pmnts.payer_inn;
       /* Байтин А.
          Это не работает... Заменено на nvl
             EXCEPTION -- Если не нашли контакт по БИКу, возьмём Платёж
               WHEN OTHERS
               THEN
                 v_contact_id := rls.contact_id;
             END;
       */
       -- Байтин А.
       /*BEGIN
         SELECT MAX(ap.payment_id) INTO v_payment
         FROM ins.ac_payment ap 
         WHERE ap.doc_txt = to_char(pmnts.code);
       EXCEPTION
         WHEN no_data_found
         THEN NULL; -- это - нормальная ситуация, такого платежа в системе ещё нет
       END;*/
     
       BEGIN
         SELECT ap.payment_id
           INTO v_payment
           FROM ins.ac_payment ap
          WHERE ap.code = pmnts.code
            AND rownum = 1;
       EXCEPTION
         -- Байтин А.
         -- Теперь ищем по полю MD5
         WHEN no_data_found THEN
           BEGIN
             SELECT ap.payment_id INTO v_payment FROM ins.ac_payment ap WHERE ap.md5 = pmnts.md5;
           EXCEPTION
             WHEN no_data_found THEN
               v_payment := NULL;
           END;
       END;
     
       -- Нет ли уже в Борласе такого платежа?
       IF v_payment IS NOT NULL
       THEN
         --DBMS_OUTPUT.PUT_LINE('Такой платеж уже есть в системе');
         pkg_gate.xx_gap_copy(-1, 'insi.xx_gap_bad', pmnts.code, pmnts.md5);
         par_bad_count := par_bad_count + 1;
         INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, v_payment, -6, SYSDATE, NULL);
       ELSE
         -- Определим ID из справочников
         SELECT MAX(f.fund_id) INTO v_fund_id FROM ins.fund f WHERE f.brief = pmnts.pp_fund;
       
         SELECT MAX(ccba.id)
           INTO v_bank_acc_id
           FROM ins.cn_contact_bank_acc ccba
          WHERE ccba.account_nr = pmnts.receiver_account;
       
         SELECT MAX(ccba.id)
           INTO v_payer_acc_id
           FROM ins.cn_contact_bank_acc ccba
          WHERE ccba.account_nr = pmnts.payer_account;
       
         SELECT ins.sq_document.nextval INTO v_doc_id FROM dual;
       
         v_setdate := SYSDATE;
       
         -- Собственно, рассчёт суммы платежа на основании комиссии текущего правила и входящего платежа 
         IF (pmnts.pp_rev_amount / 100 * rls.commission_rate) < rls.min_commission
         THEN
           v_gross := pmnts.pp_rev_amount + rls.min_commission;
         ELSE
           v_gross := pmnts.pp_rev_amount / (1 - rls.commission_rate / 100);
         END IF;
       
         --/Чирков/ 333541: Проблема с платежами ХКФ СРОЧНО
         
         --333541
         v_set_off_state := null;
          IF pmnts.payer_bank_bic = '044585216'
             AND v_company_bank_acc = '40701810600010000030'
           and v_payer_bank_name = 'ООО "ХКФ БАНК"'
           then
               select xx.val
               into v_set_off_state
               from ins.xx_lov_list xx
               where xx.description = 'Банки'
               and xx.name = 'PAYMENT_SET_OFF_STATE';
           end if;
           
         -- Блок вставки данных. Если завершается неуспешно, то обрабатываемая строка помещается в таблицу BAD
         BEGIN
           -- Создаем платежный документ
           BEGIN
             SAVEPOINT ins_payment;
            
              v_ap_contact_id := get_bank_contact_id(pmnts.payer_bank_bic);
              IF v_ap_contact_id IS NOT NULL
              THEN
                v_bank_contact_name := ins.ent.obj_name(22, v_ap_contact_id); -- contact ent_id
              ELSE
                v_ap_contact_id     := v_contact_id;
                v_bank_contact_name := v_payer_bank_name;
              END IF;
            
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
                --                      ,company_bank_acc_id  --19
                --                      ,contact_bank_acc_id  --20
               ,company_bank_account_num --19
               ,contact_bank_account_num --20
               ,rev_amount --21
               ,code --22
               ,md5 --23
               ,contact_name --24
               ,payer_bank_name --25
               ,payer_inn --26
               ,t_commission_rules_id
               ,set_off_state)
             VALUES
               (1 --1 Курс приведения
               ,rls.t_col_method_id --2 Способ оплаты текущего правила
               ,v_payment_terms_id --3
                ,v_ap_contact_id --4
               ,v_fund_id --5
               ,pmnts.pp_date --6
               ,-1 --7 Номер платежа ЭПГ, у нас -1
               ,pmnts.pp_num --8
               ,rls.main_doc_templ_id --9 Тип документа (ОБЩИЙ)
               ,pmnts.payer_name || ' ' || pmnts.pp_note || ' FROM NAVISION' --10
               ,pmnts.pp_date --11
               ,v_doc_id --12
               ,1 --13 Фактический, константа
               ,0 --14 Входящий, константа
               ,pmnts.pp_bnr_date --15
               ,v_gross --16
               ,v_fund_id --17
               ,rls.payment_templ_id --18 Тип документа (ПЛАТЁЖНОГО)
                --                      ,v_bank_acc_id        --19
                --                      ,v_payer_acc_id       --20
               ,v_company_bank_acc --19
               ,v_contact_bank_acc --20
               ,pmnts.pp_rev_amount --21 Исходная сумма
               ,pmnts.code --22
               ,pmnts.md5 --23
               ,v_contact_name --24
                ,v_bank_contact_name --25
               ,v_payer_inn --26
               ,rls.t_commission_rules_id
               ,v_set_off_state);
           EXCEPTION
             WHEN OTHERS THEN
               --RAISE_APPLICATION_ERROR(-20111, 'ОШИБКА ВСТАВКИ ПЛАТЕЖА!');
               --dbms_output.put_line('ОШИБКА ВСТАВКИ ПЛАТЕЖА! '||SQLERRM);
               --ROLLBACK TO ins_payment;
               INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, NULL, -11, SYSDATE, NULL);
               RETURN;
           END;
         
           --DBMS_OUTPUT.PUT_LINE('Платёж num: '||pmnts.pp_num||', payment_id: '||v_doc_id||', doc_txt: '||pmnts.code);
           -- Созданному платёжному документу ставим статус "Документ добавлен"
           BEGIN
             INSERT INTO ins.ven_doc_status
               (document_id, doc_status_ref_id, start_date)
             VALUES
               (v_doc_id, 0, SYSDATE); -- "Документ добавлен"
           EXCEPTION
             WHEN OTHERS THEN
               --RAISE_APPLICATION_ERROR(-20222, 'ОШИБКА ВСТАВКИ СТАТУСА!');
               --dbms_output.put_line('ОШИБКА ВСТАВКИ СТАТУСА!'||SQLERRM);
               ROLLBACK TO ins_payment;
               INSERT INTO insi.ven_xx_gap_process_log
               VALUES
                 (pmnts.code, NULL, -12, v_setdate, NULL);
               RETURN;
           END;
         
           -- Устанавливаем ему статус Новый
           --v_setdate := v_setdate + INTERVAL '10' SECOND;
           BEGIN
             ins.doc.set_doc_status(v_doc_id, 'NEW' /*, v_setdate*/);
           EXCEPTION
             WHEN OTHERS THEN
               --RAISE_APPLICATION_ERROR(-20444, 'ОШИБКА ФОРМИРОВАНИЯ СТАТУСА!'||SQLERRM);
               --DBMS_OUTPUT.PUT_LINE('ОШИБКА ФОРМИРОВАНИЯ СТАТУСА Новый! '||SQLERRM);
               ROLLBACK TO ins_payment;
               INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, NULL, -14, SYSDATE, NULL);
               RETURN;
           END;
         
           -- Устанавливаем ему статус Проведен
           --v_setdate := v_setdate + INTERVAL '10' SECOND;
           BEGIN
             ins.doc.set_doc_status(v_doc_id, 'TRANS' /*, v_setdate*/);
           EXCEPTION
             WHEN OTHERS THEN
               --dbms_output.put_line('ОШИБКА ФОРМИРОВАНИЯ СТАТУСА Проведен!'||SQLERRM);
               --RAISE_APPLICATION_ERROR(-20445, 'ОШИБКА ФОРМИРОВАНИЯ СТАТУСА!'||SQLERRM);
               INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, NULL, -15, SYSDATE, NULL);
           END;
         
           BEGIN
             pkg_gate.xx_gap_copy(v_doc_id, 'insi.xx_gap_good', pmnts.code, pmnts.md5);
             par_good_count := par_good_count + 1;
             IF v_contact_id = v_cn_imp_error
             THEN
               INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, NULL, -18, SYSDATE, NULL);
             ELSE
               INSERT INTO insi.ven_xx_gap_process_log
               VALUES
                 (pmnts.code, v_doc_id, 1, SYSDATE, NULL);
             END IF;
           EXCEPTION
             WHEN OTHERS THEN
               --RAISE_APPLICATION_ERROR(-20333, 'ОШИБКА КОПИРОВАНИЯ!');
               --dbms_output.put_line('ОШИБКА КОПИРОВАНИЯ!');
               INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, NULL, -13, SYSDATE, NULL);
           END;
         EXCEPTION
           WHEN OTHERS THEN
             --dbms_output.put_line('OTHERS');
             pkg_gate.xx_gap_copy(-2, 'insi.xx_gap_bad', pmnts.code, pmnts.md5);
             par_bad_count := par_bad_count + 1;
             --RAISE_APPLICATION_ERROR(-20555, 'НЕОПОЗНАННАЯ ОШИБКА!'||SQLERRM);
             INSERT INTO insi.ven_xx_gap_process_log VALUES (pmnts.code, NULL, -7, SYSDATE, NULL);
         END;
       END IF;
     END LOOP pmnts;
     IF rls.operation_type = 0
     THEN
       CLOSE c_payments_or;
     ELSE
       CLOSE c_payments_and;
     END IF;
     COMMIT;
   END LOOP rls;
   -- Количество оставшихся записей
   SELECT COUNT(*) INTO par_left_count FROM insi.xx_gap;
 END xx_gap_copy_main_new;

  PROCEDURE xx_gap_main AS
  BEGIN
    xx_gap_copy_main;
  END xx_gap_main;

  --процедура привязки входящих платежей к договорам страхования
  PROCEDURE xx_gap_process_old AS
    CURSOR c_payments IS(
      SELECT upper(translate(d.note, 'x ,.', 'x')) AS note
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
                     ,upper(REPLACE(cn.obj_name_orig, ' ', '')) i_name
                     ,upper(substr(cn.obj_name_orig, 1, regexp_instr(cn.obj_name_orig, ' ', 1, 1) - 1) ||
                            substr(cn.obj_name_orig, regexp_instr(cn.obj_name_orig, ' ', 1, 1) + 1, 1) ||
                            substr(cn.obj_name_orig, regexp_instr(cn.obj_name_orig, ' ', 1, 2) + 1, 1)) i_name_s
                      --родительный падеж
                     ,upper(REPLACE(cn.genitive, ' ', '')) i_name_gen
                     ,upper(substr(cn.genitive, 1, regexp_instr(cn.genitive, ' ', 1, 1) - 1) ||
                            substr(cn.genitive, regexp_instr(cn.genitive, ' ', 1, 1) + 1, 1) ||
                            substr(cn.genitive, regexp_instr(cn.genitive, ' ', 1, 2) + 1, 1)) i_name_s_gen
                      --винительный падеж
                     ,upper(REPLACE(cn.accusative, ' ', '')) i_name_acc
                     ,upper(substr(cn.accusative, 1, regexp_instr(cn.accusative, ' ', 1, 1) - 1) ||
                            substr(cn.accusative, regexp_instr(cn.accusative, ' ', 1, 1) + 1, 1) ||
                            substr(cn.accusative, regexp_instr(cn.accusative, ' ', 1, 2) + 1, 1)) i_name_s_acc
                      --дательный падеж
                     ,upper(REPLACE(cn.dative, ' ', '')) i_name_dat
                     ,upper(substr(cn.dative, 1, regexp_instr(cn.dative, ' ', 1, 1) - 1) ||
                            substr(cn.dative, regexp_instr(cn.dative, ' ', 1, 1) + 1, 1) ||
                            substr(cn.dative, regexp_instr(cn.dative, ' ', 1, 2) + 1, 1)) i_name_s_dat
                      --творительный падеж
                     ,upper(REPLACE(cn.instrumental, ' ', '')) i_name_ins
                     ,upper(substr(cn.instrumental, 1, regexp_instr(cn.instrumental, ' ', 1, 1) - 1) ||
                            substr(cn.instrumental, regexp_instr(cn.instrumental, ' ', 1, 1) + 1, 1) ||
                            substr(cn.instrumental, regexp_instr(cn.instrumental, ' ', 1, 2) + 1, 1)) i_name_s_ins
                      --далее идет все по застрахованному
                      --именительный падеж Застр
                     ,upper(REPLACE(cn_ins.obj_name_orig, ' ', '')) i_name_z
                     ,upper(substr(cn_ins.obj_name_orig
                                  ,1
                                  ,regexp_instr(cn_ins.obj_name_orig, ' ', 1, 1) - 1) ||
                            substr(cn_ins.obj_name_orig
                                  ,regexp_instr(cn_ins.obj_name_orig, ' ', 1, 1) + 1
                                  ,1) || substr(cn_ins.obj_name_orig
                                               ,regexp_instr(cn_ins.obj_name_orig, ' ', 1, 2) + 1
                                               ,1)) i_name_s_z
                      --родительный падеж
                     ,upper(REPLACE(cn_ins.genitive, ' ', '')) i_name_gen_z
                     ,upper(substr(cn_ins.genitive, 1, regexp_instr(cn_ins.genitive, ' ', 1, 1) - 1) ||
                            substr(cn_ins.genitive, regexp_instr(cn_ins.genitive, ' ', 1, 1) + 1, 1) ||
                            substr(cn_ins.genitive, regexp_instr(cn_ins.genitive, ' ', 1, 2) + 1, 1)) i_name_s_gen_z
                      --винительный падеж
                     ,upper(REPLACE(cn_ins.accusative, ' ', '')) i_name_acc_z
                     ,upper(substr(cn_ins.accusative
                                  ,1
                                  ,regexp_instr(cn_ins.accusative, ' ', 1, 1) - 1) ||
                            substr(cn_ins.accusative
                                  ,regexp_instr(cn_ins.accusative, ' ', 1, 1) + 1
                                  ,1) || substr(cn_ins.accusative
                                               ,regexp_instr(cn_ins.accusative, ' ', 1, 2) + 1
                                               ,1)) i_name_s_acc_z
                      --дательный падеж
                     ,upper(REPLACE(cn_ins.dative, ' ', '')) i_name_dat_z
                     ,upper(substr(cn_ins.dative, 1, regexp_instr(cn_ins.dative, ' ', 1, 1) - 1) ||
                            substr(cn_ins.dative, regexp_instr(cn_ins.dative, ' ', 1, 1) + 1, 1) ||
                            substr(cn_ins.dative, regexp_instr(cn_ins.dative, ' ', 1, 2) + 1, 1)) i_name_s_dat_z
                      --творительный падеж
                     ,upper(REPLACE(cn_ins.instrumental, ' ', '')) i_name_ins_z
                     ,upper(substr(cn_ins.instrumental
                                  ,1
                                  ,regexp_instr(cn_ins.instrumental, ' ', 1, 1) - 1) ||
                            substr(cn_ins.instrumental
                                  ,regexp_instr(cn_ins.instrumental, ' ', 1, 1) + 1
                                  ,1) || substr(cn_ins.instrumental
                                               ,regexp_instr(cn_ins.instrumental, ' ', 1, 2) + 1
                                               ,1)) i_name_s_ins_z
        FROM ins.p_policy     pp
            ,ins.contact      cn
            ,ins.contact      cn_ins
            ,ins.p_pol_header ph
       WHERE ins.pkg_policy.get_policy_contact(pp.policy_id, 'Страхователь') = cn.contact_id(+)
         AND ins.pkg_policy.get_policy_contact(pp.policy_id, 'Застрахованное лицо') =
             cn_ins.contact_id(+)
         AND (pp.pol_num LIKE '%' || p_polnum OR pp.notice_num LIKE '%' || p_polnum)
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
                    ,row_number() over(PARTITION BY pp.policy_id ORDER BY ap.plan_date ASC) rnum
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
                            COMMIT;
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
                            ROLLBACK;
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
      COMMIT;
    END LOOP;
  END xx_gap_process_old;

  --------------------------------------------------------------------------
  PROCEDURE xx_gap_process
  --------------------------------------------------------------------------
   AS
    v_found        VARCHAR2(20);
    v_status       NUMBER;
    v_dso_id       NUMBER;
    v_error_level  NUMBER;
    v_stage        NUMBER := 0;
    v_doc_templ_id NUMBER;
    --------------------------
    v_c_0  NUMBER := 0;
    v_c_1  NUMBER := 0;
    v_c_2  NUMBER := 0;
    v_c_4  NUMBER := 0;
    v_c_5  NUMBER := 0;
    v_c_17 NUMBER := 0;
    v_c_19 NUMBER := 0;
  
    --------------------------
    CURSOR c_payments IS(
      SELECT regexp_replace(d.note, '[^[:digit:]]{1,}', ',') digit_array
            ,
             --выкидываем все "не цифры"
             upper(d.note) note
            ,d.document_id
            ,d.num
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
      SELECT p.pol_header_id phid
            ,p.pol_num pol_num
            ,upper(cn.name) cn_name
            ,upper(regexp_substr(cn.genitive, '[[:alpha:]]{1,}')) cn_genitive
            ,upper(regexp_substr(cn.accusative, '[[:alpha:]]{1,}')) cn_accusative
            ,upper(regexp_substr(cn.dative, '[[:alpha:]]{1,}')) cn_dative
            ,upper(regexp_substr(cn.instrumental, '[[:alpha:]]{1,}')) cn_instrumental
            ,upper(cn_ins.name) cn_ins_name
            ,upper(regexp_substr(cn_ins.genitive, '[[:alpha:]]{1,}')) cn_ins_genitive
            ,upper(regexp_substr(cn_ins.accusative, '[[:alpha:]]{1,}')) cn_ins_accusative
            ,upper(regexp_substr(cn_ins.dative, '[[:alpha:]]{1,}')) cn_ins_dative
            ,upper(regexp_substr(cn_ins.instrumental, '[[:alpha:]]{1,}')) cn_ins_instrumental
        FROM ins.p_policy       p
            ,ins.doc_status     ds
            ,ins.doc_status_ref dsf
            ,ins.contact        cn
            ,ins.contact        cn_ins
       WHERE (p.pol_header_id, p.version_num) IN
             (SELECT pp.pol_header_id
                    ,MAX(pp.version_num) max_version
                FROM ins.p_policy pp
               WHERE (pp.pol_num LIKE '%' || p_polnum || '%' OR
                     pp.notice_num LIKE '%' || p_polnum || '%')
               GROUP BY pp.pol_header_id)
         AND ds.document_id = p.policy_id
         AND ds.start_date =
             (SELECT MAX(dsm.start_date) FROM ins.doc_status dsm WHERE dsm.document_id = p.policy_id)
         AND ds.doc_status_ref_id = dsf.doc_status_ref_id
         AND dsf.brief NOT IN
             ('READY_TO_CANCEL', 'BREAK', 'CANCEL', 'ANNULATED', 'INDEXATING', 'PROJECT')
         AND ins.pkg_policy.get_policy_contact(p.policy_id, 'Страхователь') = cn.contact_id(+)
         AND ins.pkg_policy.get_policy_contact(p.policy_id, 'Застрахованное лицо') =
             cn_ins.contact_id(+));
  
    --все элементы план-графика выбранного полиса (по policy_id)
    CURSOR c_epg(p_phid NUMBER) IS(
      SELECT *
        FROM (SELECT *
                FROM (SELECT ap.amount
                            ,ap.payment_id
                            ,pp.pol_num
                            ,pp.start_date
                            ,ap.plan_date
                            ,ins.pkg_payment.get_set_off_amount(ap.payment_id, pp.pol_header_id, NULL) part_pay_amount
                            ,row_number() over(PARTITION BY pp.policy_id ORDER BY ap.plan_date ASC) rnum
                            ,pp.policy_id
                            ,ins.doc.get_doc_status_id(ap.payment_id, SYSDATE) status
                        FROM ins.p_policy   pp
                            ,ins.doc_doc    dd
                            ,ins.ac_payment ap
                       WHERE pp.policy_id = dd.parent_id
                         AND dd.child_id = ap.payment_id
                         AND ins.doc.get_doc_status_id(ap.payment_id, SYSDATE) = 22
                            --"к оплате" соотв
                         AND ap.payment_templ_id = 1 --Счет на оплату взносов
                         AND pp.pol_header_id = p_phid)
               WHERE rnum <= 2
              UNION (SELECT ap.amount
                          ,ap.payment_id
                          ,pp.pol_num
                          ,pp.start_date
                          ,ap.plan_date
                          ,ins.pkg_payment.get_set_off_amount(ap.payment_id, pp.pol_header_id, NULL) part_pay_amount
                          ,row_number() over(PARTITION BY pp.policy_id ORDER BY ap.plan_date ASC) rnum
                          ,pp.policy_id
                          ,ins.doc.get_doc_status_id(ap.payment_id, SYSDATE) status
                      FROM ins.p_policy   pp
                          ,ins.doc_doc    dd
                          ,ins.ac_payment ap
                     WHERE pp.policy_id = dd.parent_id
                       AND dd.child_id = ap.payment_id
                       AND ins.doc.get_doc_status_id(ap.payment_id, SYSDATE) = 6 --"оплачен" соотв
                       AND ap.payment_templ_id = 1 --Счет на оплату взносов
                       AND pp.pol_header_id = p_phid
                       AND EXISTS (SELECT 1
                              FROM ins.doc_set_off dso
                                  ,ins.document    dc
                             WHERE ap.payment_id = dso.parent_doc_id
                               AND dso.child_doc_id = dc.document_id
                               AND dc.doc_templ_id IN (5234, 6531)))
               ORDER BY 9 DESC
                       ,5 ASC));
  
    --курсор, возвращающий все ЭПГ в статусе "Оплачен" по заданному phid
    CURSOR c_epg_opl(p_phid NUMBER) IS(
      SELECT vap.payment_id
            ,(vap.amount + vap.comm_amount) list_doc_amount
            ,vap.amount
            ,ins.pkg_payment.get_set_off_amount(vap.payment_id, pp.pol_header_id, NULL) part_pay_amount
            ,vap.grace_date
        FROM ins.p_policy       pp
            ,ins.doc_doc        dd
            ,ins.ven_ac_payment vap
       WHERE pp.policy_id = dd.parent_id
         AND dd.child_id = vap.payment_id
         AND ins.doc.get_doc_status_id(vap.payment_id, SYSDATE) = 6 --"оплачен"
         AND vap.doc_templ_id = 4 --Счет на оплату взносов
         AND pp.pol_header_id = p_phid);
  
    --курсор, возвращающий все ПД типа А7 и ПД4 по заданному epg_id
    CURSOR c_a7pd4(p_epg_opl_id NUMBER) IS(
      SELECT vap_a7pd4.payment_id     a7pd4_id
            ,vap_a7pd4.contact_id     a7pd4_cnid
            ,vap_a7pd4.fund_id        a7pd4_fundid
            ,vap_a7pd4.due_date       a7pd4_duedate
            ,vap_a7pd4.reg_date       a7pd4_regdate
            ,vap_a7pd4.payment_number a7pd4_paynum
            ,vap_a7pd4.num            a7pd4_docnum
            ,vap_a7pd4.doc_templ_id   a7pd4_dtid
            ,vap_a7pd4.amount         a7pd4_amnt
            ,vap_a7pd4.rev_amount     a7pd4_revamnt
            ,vap_a7pd4.rev_rate       a7pd4_revrate
        FROM ins.doc_set_off    dso
            ,ins.ven_ac_payment vap_a7pd4
       WHERE dso.parent_doc_id = p_epg_opl_id
         AND dso.child_doc_id = vap_a7pd4.payment_id
         AND vap_a7pd4.doc_templ_id IN (5234, 6531) --А7 и ПД4
       );
  
    --курсор, возвращающий сумму документов всех реальных ПП, которыми оплачены фиктивные А7 или ПД4
    CURSOR с_a7pd4_pp(p_a7pd4_id NUMBER) IS(
      SELECT nvl(SUM(ap_pp.amount), 0) sum_pp
            ,dd_copy.child_id a7pd4_copy_id
        FROM ins.doc_doc     dd_copy
            ,ins.doc_set_off dso_copy
            ,ins.ac_payment  ap_pp
       WHERE p_a7pd4_id = dd_copy.parent_id
         AND dd_copy.child_id = dso_copy.parent_doc_id(+)
         AND dso_copy.child_doc_id = ap_pp.payment_id(+)
       GROUP BY dd_copy.child_id);
  BEGIN
    --цикл по платежам
    FOR v_payments IN c_payments
    LOOP
      v_stage  := 10;
      v_status := 0;
    
      --цикл по вариантам шаблонов с разбором строки
      <<payment>>
      FOR x IN (SELECT CASE
                         WHEN (length(n) < 6) THEN
                          lpad(n, 6, '0')
                       --вставляем лидирующие нули везде где менее 6-ти символов
                         ELSE
                          n
                       END n
                  FROM (SELECT DISTINCT regexp_substr(v_payments.digit_array, '[[:digit:]]{4,}', 1, c) n
                        --всё что меньше 4-х символов выкидываем
                          FROM dual
                              ,(SELECT LEVEL c FROM dual CONNECT BY LEVEL < 20) d)
                --предполагается не более 20-ти отдельно стоящих цифр
                 WHERE n IS NOT NULL)
      LOOP
        v_stage := 20;
      
        --цикл по полисам, подходящим под шаблон
        FOR v_policy IN c_policy(x.n)
        LOOP
          v_stage := 30;
        
          --Проверка по наличию фамилии
          IF instr(v_payments.note, v_policy.cn_name) <> 0
             OR instr(v_payments.note, v_policy.cn_genitive) <> 0
             OR instr(v_payments.note, v_policy.cn_accusative) <> 0
             OR instr(v_payments.note, v_policy.cn_dative) <> 0
             OR instr(v_payments.note, v_policy.cn_instrumental) <> 0
             OR instr(v_payments.note, v_policy.cn_ins_name) <> 0
             OR instr(v_payments.note, v_policy.cn_ins_genitive) <> 0
             OR instr(v_payments.note, v_policy.cn_ins_accusative) <> 0
             OR instr(v_payments.note, v_policy.cn_ins_dative) <> 0
             OR instr(v_payments.note, v_policy.cn_ins_instrumental) <> 0
          THEN
            v_stage := 35;
          
            --цикл по элементам плана-графика, данного полиса
            FOR v_epg IN c_epg(v_policy.phid)
            LOOP
              v_stage := 40;
              SAVEPOINT cre_doc; --точка отката на случай неудачного создания
            
              IF v_epg.status = 6
              THEN
                v_stage := 50;
              
                --пройдемся по ЭПГ в статусе 'Оплачен'
                FOR v_epg_opl IN c_epg_opl(v_policy.phid)
                LOOP
                  v_stage := 60;
                
                  FOR v_a7pd4 IN c_a7pd4(v_epg_opl.payment_id)
                  LOOP
                    v_stage := 70;
                  
                    FOR v_a7pd4_pp IN с_a7pd4_pp(v_a7pd4.a7pd4_id)
                    LOOP
                      v_stage := 80;
                      dbms_output.put_line('Payment №' || v_payments.num || ' v_payments.amount - ' ||
                                           v_payments.amount || ' v_policy.pol_num - ' ||
                                           v_policy.pol_num || ' v_epg_opl.list_doc_amount - ' ||
                                           v_epg_opl.list_doc_amount || ' v_a7pd4_pp.sum_pp - ' ||
                                           v_a7pd4_pp.sum_pp || ' d = ' ||
                                           (v_epg_opl.list_doc_amount - nvl(v_a7pd4_pp.sum_pp, 0) -
                                           v_payments.amount) || '/' || v_payments.amount);
                    
                      IF v_payments.amount <> 0
                         AND abs((v_epg_opl.list_doc_amount - nvl(v_a7pd4_pp.sum_pp, 0) -
                                 v_payments.amount) / (v_payments.amount)) <= 0.001
                      THEN
                        v_stage := 90;
                      
                        IF (v_epg_opl.list_doc_amount - nvl(v_a7pd4_pp.sum_pp, 0) >= v_payments.amount)
                        THEN
                          v_stage := 100;
                        
                          BEGIN
                            SELECT ins.sq_doc_set_off.nextval INTO v_dso_id FROM dual;
                          
                            v_stage := 105;
                          
                            SELECT dt.doc_templ_id
                              INTO v_doc_templ_id
                              FROM ins.doc_templ dt
                             WHERE dt.brief = 'ЗАЧПЛ';
                          
                            dbms_output.put_line(', v_dso_id = ' || v_dso_id ||
                                                 ', v_a7pd4.a7pd4_dtid = ' || v_a7pd4.a7pd4_dtid ||
                                                 ', NOTE = ' ||
                                                 'документ зачета для привязки ПП из NAVISION' ||
                                                 ', REG_DATE = ' || SYSDATE ||
                                                 ', v_a7pd4_pp.a7pd4_copy_id = ' ||
                                                 v_a7pd4_pp.a7pd4_copy_id ||
                                                 ', v_payments.document_id = ' ||
                                                 v_payments.document_id || ', v_a7pd4.a7pd4_amnt = ' ||
                                                 v_a7pd4.a7pd4_amnt || ', v_a7pd4.a7pd4_amnt = ' ||
                                                 v_a7pd4.a7pd4_amnt || ', v_a7pd4.a7pd4_fundid = ' ||
                                                 v_a7pd4.a7pd4_fundid || ', v_a7pd4.a7pd4_fundid = ' ||
                                                 v_a7pd4.a7pd4_fundid || ', v_a7pd4.a7pd4_revrate = ' ||
                                                 v_a7pd4.a7pd4_revrate || ', v_payments_due_date = ' ||
                                                 v_payments.due_date);
                          
                            --создать документ зачета от копии а7пд4 до реального ПП
                            INSERT INTO ins.ven_doc_set_off
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
                              ,v_doc_templ_id
                              ,'документ зачета для привязки ПП из NAVISION'
                              ,SYSDATE
                              ,v_payments.document_id
                              ,v_a7pd4_pp.a7pd4_copy_id
                              ,v_a7pd4.a7pd4_amnt
                              ,v_a7pd4.a7pd4_amnt
                              ,v_a7pd4.a7pd4_fundid
                              ,SYSDATE
                              ,v_a7pd4.a7pd4_fundid
                              ,v_a7pd4.a7pd4_revrate);
                          
                            v_stage := 110;
                          
                            INSERT INTO ins.ven_doc_status
                              (document_id, doc_status_ref_id, start_date)
                            VALUES
                              (v_dso_id
                              ,0 --статус документа "Документ добавлен"
                              ,SYSDATE);
                          
                            v_stage := 120;
                            --меняем ему статус
                            ins.doc.set_doc_status(v_dso_id, 'NEW', v_payments.due_date);
                            v_stage := 130;
                            dbms_output.put_line(v_payments.note);
                            dbms_output.put_line('Документ №' || v_payments.num || ' на сумму:' ||
                                                 v_payments.amount || ' привязывается к ' ||
                                                 v_policy.pol_num || '. a7/pd4 - ' ||
                                                 v_a7pd4.a7pd4_paynum);
                            EXIT payment; --если пришли сюда - значит всё привязали
                          EXCEPTION
                            WHEN OTHERS THEN
                              ROLLBACK TO cre_doc;
                              dbms_output.put_line('v_stage - ' || v_stage);
                              dbms_output.put_line(SQLERRM);
                            
                              CASE v_stage
                                WHEN 100 THEN
                                  dbms_output.put_line('Ошибка "INSERT INTO ins.ven_doc_set_off vdso ..." ');
                                WHEN 110 THEN
                                  dbms_output.put_line('Ошибка "INSERT INTO ins.ven_doc_status ..." ');
                                WHEN 120 THEN
                                  dbms_output.put_line('Ошибка "ins.doc.set_doc_status ..." ' ||
                                                       v_dso_id);
                                ELSE
                                  NULL;
                              END CASE;
                          END;
                        END IF;
                      END IF;
                    END LOOP; --v_a7pd4_pp
                  END LOOP; --v_a7pd4
                END LOOP; --v_epg_opl
              ELSE
                v_stage := 200;
              
                --если сумма сошлась - можно привязывать
                IF v_payments.amount <> 0
                   AND abs((v_epg.amount - v_epg.part_pay_amount - v_payments.amount) /
                           (v_payments.amount)) <= 0.001
                THEN
                  v_stage := 210;
                
                  IF (v_epg.amount - v_epg.part_pay_amount >= v_payments.amount)
                  THEN
                    v_stage := 220;
                    dbms_output.put_line(v_payments.document_id || '|||' || v_epg.payment_id || '|||' ||
                                         v_policy.pol_num || '|||' || v_payments.amount || '|||' ||
                                         v_epg.amount || '|||' || v_epg.plan_date || '|||' ||
                                         ' - УРА! - можно привязывать');
                  
                    --создаем документ зачета
                    BEGIN
                      SELECT ins.sq_doc_set_off.nextval INTO v_dso_id FROM dual;
                    
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
                    
                      v_stage := 230;
                    
                      INSERT INTO ins.ven_doc_status
                        (document_id, doc_status_ref_id, start_date)
                      VALUES
                        (v_dso_id
                        ,0 --статус документа "Документ добавлен"
                        ,SYSDATE);
                    
                      v_stage := 240;
                      --меняем ему статус на "Новый" - при этом он зачитывается
                      ins.doc.set_doc_status(v_dso_id, 'NEW', v_payments.due_date);
                      v_stage := 250;
                      --Помечаем платёж как Разнесённый
                      UPDATE ins.ac_payment ap
                         SET ap.set_off_state =
                             (SELECT l.val
                                FROM ins.xx_lov_list l
                               WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                                 AND l.description = 'Разнесено')
                       WHERE ap.payment_id = v_payments.document_id;
                    
                      dbms_output.put_line(v_payments.note);
                      dbms_output.put_line('Документ №' || v_payments.num || ' на сумму:' ||
                                           v_payments.amount || ' привязывается к ' ||
                                           v_policy.pol_num || '. Новый на дату - ' ||
                                           v_epg.plan_date);
                      EXIT payment; --если пришли сюда - значит всё привязали
                    EXCEPTION
                      WHEN OTHERS THEN
                        ROLLBACK TO cre_doc;
                        dbms_output.put_line('v_stage - ' || v_stage);
                        dbms_output.put_line(SQLERRM);
                      
                        CASE v_stage
                          WHEN 220 THEN
                            dbms_output.put_line('Ошибка "INSERT INTO ins.ven_doc_set_off vdso ..." ');
                          WHEN 230 THEN
                            dbms_output.put_line('Ошибка "INSERT INTO ins.ven_doc_status ..." ');
                          WHEN 240 THEN
                            dbms_output.put_line('Ошибка "ins.doc.set_doc_status ..." ' || v_dso_id);
                          WHEN 250 THEN
                            dbms_output.put_line('Ошибка "UPDATE ins.ac_payment ap ..." ' ||
                                                 v_payments.document_id);
                          ELSE
                            NULL;
                        END CASE;
                    END;
                  END IF;
                END IF;
              END IF;
            END LOOP; --v_epg цикл по элементам план-графика полиса
          END IF;
        END LOOP; --v_policy
      END LOOP; --цикл по вариантам
    
      CASE
        WHEN v_stage = 10 THEN
          --В поле "Назначение платежа" не найден номер договора/заявления
          v_status := -1;
        WHEN v_stage = 20 THEN
          --В Борлас не найдено ни одного договора/заявления с номером из поля "Назначение платежа"
          v_status := -2;
        WHEN v_stage = 30 THEN
          --Не найдена фамилия
          v_status := -3;
        WHEN v_stage = 35 THEN
          --План-график по договору не содержит платежей в статусе "К оплате"
          v_status := -4;
        WHEN v_stage = 80
             OR v_stage = 200 THEN
          --Относительное отклонение суммы платежа от суммы графика больше 0,01%
          v_status := -5;
        WHEN v_stage = 90
             OR v_stage = 210 THEN
          --Сумма ППВХ больше суммы к зачету с ЭПГ
          v_status := -19;
        WHEN v_stage = 130
             OR v_stage = 250 THEN
          --Ок
          v_status := 0;
        ELSE
          v_status := -17;
      END CASE;
    
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
          v_c_17 := v_c_17 + 1;
      END CASE;
    
      --вставка данных в лог
      UPDATE xx_gap_process_log l
         SET document_id = v_dso_id
            ,status_id   = v_status
            ,status_date = SYSDATE
       WHERE l.code = v_payments.code
         AND l.status_id <> 0
         AND EXISTS (SELECT NULL
                FROM xx_gap_status_ref g
               WHERE l.status_id = g.status_id
                 AND g.status_type = 1); --только логи привязки
    
      IF SQL%ROWCOUNT = 0
      THEN
        INSERT INTO xx_gap_process_log l VALUES (v_payments.code, v_dso_id, v_status, SYSDATE, NULL);
      END IF;
      v_dso_id := NULL;
    END LOOP;
  
    dbms_output.put_line('v_c_0 - ' || v_c_0 || ' Ok');
    dbms_output.put_line('v_c_1 - ' || v_c_1 ||
                         ' В поле "Назначение платежа" не найден номер договора/заявления');
    dbms_output.put_line('v_c_2 - ' || v_c_2 ||
                         ' Борлас не найдено ни одного договора/заявления с номером из поля "Назначение платежа"');
    dbms_output.put_line('v_c_4 - ' || v_c_4 ||
                         ' План-график по договору не содержит платежей в статусе "К оплате"');
    dbms_output.put_line('v_c_5 - ' || v_c_5 ||
                         ' Относительное отклонение суммы платежа от суммы графика больше 0,01%');
    dbms_output.put_line('v_c_17 - ' || v_c_17 || ' Ошибка при выполнении процедуры автопривязки');
    dbms_output.put_line('v_c_19 - ' || v_c_19 || ' Сумма ППВХ больше суммы к зачету с ЭПГ');
    dbms_output.put_line(v_c_0 + v_c_1 + v_c_2 + v_c_4 + v_c_5 + v_c_19);
    COMMIT;
  END xx_gap_process;

--------------------------
END pkg_gate; 
/

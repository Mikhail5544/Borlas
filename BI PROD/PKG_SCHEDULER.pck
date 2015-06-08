CREATE OR REPLACE PACKAGE PKG_SCHEDULER IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.01.2010 16:26:29
  -- Purpose : ������ ���������� ��������

  PROCEDURE Run_scheduled
  (
    p_name     VARCHAR2
   ,p_code     VARCHAR
   ,p_parallel PLS_INTEGER
  );
  PROCEDURE Clear_chain
  (
    p_chain_name VARCHAR2
   ,drop_chain   PLS_INTEGER DEFAULT 0
  );
  /*
    ����� ����� ���������
  */
  /*
    ������ �.
    ������ ������� ��������� �������� �������
  */
  PROCEDURE insert_queue
  (
    par_job_name VARCHAR2
   ,par_plsql    VARCHAR2
  );

  /* ������ �.
    ������ job'�
    ����������� �� ��������� job'a: JOB_QUEUE_MONITORING
  */
  PROCEDURE run_queue(par_job_name VARCHAR2);
  /*
    ������ �.
    ������� job ��� ���������� �� ��������
  */
  PROCEDURE create_monitoring_job;

END PKG_SCHEDULER;
/
CREATE OR REPLACE PACKAGE BODY PKG_SCHEDULER IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.01.2010 16:35:32
  -- Purpose : �������� ������������� ������

  gc_job_pref       CONSTANT VARCHAR2(4) := 'JOB_';
  gc_monitoring_job CONSTANT VARCHAR2(30) := 'JOB_QUEUE_MONITORING';

  -- drop_chain - ������� �� ���� ����?
  PROCEDURE Clear_chain
  (
    p_chain_name VARCHAR2
   ,drop_chain   PLS_INTEGER DEFAULT 0
  ) IS
    proc_name VARCHAR2(25) := 'Clear_chain';
  BEGIN
  
    --1) ������� ��������� ���� ��� ����
    FOR r IN (SELECT DISTINCT cp.program_name
                FROM Dba_Scheduler_Chain_Steps cs
                    ,dba_scheduler_programs    cp
               WHERE 1 = 1
                 AND chain_name = p_chain_name
                 AND cs.program_name = cp.program_name)
    LOOP
      dbms_scheduler.drop_program(r.program_name, TRUE);
    END LOOP;
  
    --2) ������� ������� ���� ��� ����
    FOR r IN (SELECT rule_name FROM Dba_Scheduler_Chain_Rules WHERE chain_name = p_chain_name)
    LOOP
      dbms_scheduler.drop_chain_rule(p_chain_name, r.RULE_NAME, TRUE);
    END LOOP;
  
    --3) ������� ������ ���� ��� ����
    FOR r IN (SELECT step_name FROM Dba_Scheduler_Chain_Steps WHERE chain_name = p_chain_name)
    LOOP
      dbms_scheduler.drop_chain_step(p_chain_name, r.step_name, TRUE);
    END LOOP;
  
    IF drop_chain = 1
    THEN
      dbms_scheduler.drop_chain(p_chain_name, TRUE);
    END IF;
  
    --4) �������� ��������� ������� ���������� �� �������
    FOR r IN (SELECT DISTINCT cp.program_name
                FROM dba_scheduler_programs cp
               WHERE 1 = 1
                 AND cp.comments = 'CHAIN_PROGRAMM'
                 AND NOT EXISTS (SELECT NULL
                        FROM Dba_Scheduler_Chain_Steps cs
                       WHERE cs.program_name = cp.program_name))
    LOOP
      dbms_scheduler.drop_program(r.program_name, TRUE);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END Clear_chain;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.01.2010 16:33:12
  -- Purpose : ������ pl/sql ���� ����� scheduler
  -- p_name - ��� ������������ ����
  -- p_code - pl/sql ���
  -- p_parallel - ����� �� ��������� ���� ��� ������������ � ��� ��������� ����������� �����?
  -- 1 - �� / 0 - ���
  PROCEDURE Run_scheduled
  (
    p_name     VARCHAR2
   ,p_code     VARCHAR
   ,p_parallel PLS_INTEGER
  ) IS
    proc_name   VARCHAR2(20) := 'Run_scheduled';
    exec_code   VARCHAR2(2000);
    v_chain_cnt PLS_INTEGER;
    v_prog_cnt  PLS_INTEGER;
    v_step_cnt  PLS_INTEGER;
    v_prog_name VARCHAR2(55);
    job_exists_err EXCEPTION;
    PRAGMA EXCEPTION_INIT(job_exists_err, -27477);
  BEGIN
  
    --������� � ������������ ��� ���������� � �������
    exec_code := 'Begin ' || CHR(10) || 'dbms_session.SET_IDENTIFIER(''' || USER || ''');' || CHR(10) ||
                 p_code || CHR(10) || 'end;';
  
    SELECT COUNT(*) INTO v_chain_cnt FROM dba_scheduler_chains sc WHERE sc.chain_name = p_name;
  
    IF v_chain_cnt = 0
    THEN
      DBMS_SCHEDULER.CREATE_CHAIN(p_name
                                 ,NULL
                                 ,NULL
                                 ,'������� ��� ���������� �������, ������� ' || USER || ' ' ||
                                  TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:mi:ss'));
      dbms_scheduler.ENABLE(p_name);
    ELSE
      --��� �������� �����
      --���� �� ������ ��� ������ ������������ ���� ������������ (���� �� ������)
      --�� �� ��� �� �������� �������� � running_chains
      --������� ���������� ������������������ � ������ ��������
      dbms_lock.sleep(0.5);
      SELECT COUNT(*)
        INTO v_chain_cnt
        FROM dba_scheduler_running_chains rc
       WHERE rc.chain_name = p_name;
    
      IF v_chain_cnt = 0
      THEN
        Clear_chain(p_name);
        dbms_scheduler.ENABLE(p_name);
      END IF;
    END IF;
  
    BEGIN
      SELECT sp.program_name
        INTO v_prog_name
        FROM dba_scheduler_programs sp
       WHERE sp.program_action = exec_code;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        -- ������ �.
        -- ������� ������ � if
        IF p_parallel = 0
        THEN
          SELECT COUNT(*)
            INTO v_prog_cnt
            FROM Dba_Scheduler_Chain_Steps cs
                ,dba_scheduler_programs    cp
           WHERE 1 = 1
             AND chain_name = p_name
             AND cs.program_name = cp.program_name;
        ELSE
          -- ������� ������� ������ ������, ����� ������� ��������� �����������������
          SELECT COUNT(*)
            INTO v_prog_cnt
            FROM dba_scheduler_programs cp
           WHERE cp.program_name LIKE p_name || '_%';
        END IF;
        v_prog_name := p_name || '_' || v_prog_cnt;
      
        dbms_scheduler.create_program(program_name   => v_prog_name
                                     ,program_type   => 'PLSQL_BLOCK'
                                     ,program_action => exec_code
                                     ,enabled        => TRUE
                                     ,comments       => 'CHAIN_PROGRAM');
    END;
  
    IF p_parallel = 1
    THEN
      v_step_cnt := 0;
    ELSE
      SELECT COUNT(*) INTO v_step_cnt FROM dba_scheduler_chain_steps cs WHERE cs.chain_name = p_name;
    END IF;
  
    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(p_name, 'STEP_' || v_step_cnt, v_prog_name);
  
    IF v_step_cnt = 0
    THEN
      DBMS_SCHEDULER.DEFINE_CHAIN_RULE(p_name, 'TRUE', 'START STEP_0');
    ELSE
      DBMS_SCHEDULER.DEFINE_CHAIN_RULE(p_name
                                      ,'STEP_' || (v_step_cnt - 1) || ' COMPLETED'
                                      ,'START STEP_' || v_step_cnt);
    END IF;
  
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE(p_name
                                    ,'STEP_' || v_step_cnt || ' COMPLETED'
                                    ,'END'
                                    ,p_name || '_END_RULE');
  
    IF v_chain_cnt = 0
    THEN
      dbms_scheduler.run_chain(p_name, '', 'JOB_' || p_name);
    ELSE
      dbms_scheduler.evaluate_running_chain('JOB_' || p_name);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END Run_scheduled;

  /*
    ������ �.
    ������ �������� ������� �� ������� � ������� + job, ��������������� �������
  */
  PROCEDURE insert_queue
  (
    par_job_name VARCHAR2
   ,par_plsql    VARCHAR2
  ) IS
  BEGIN
    -- ��������� ������������ �������� job'�
    IF length(par_job_name) > 26
    THEN
      raise_application_error(-20001
                             ,'����� �������� job''� �� ������ ��������� 26 ��������');
    END IF;
    IF regexp_like(par_job_name, '^\d')
    THEN
      raise_application_error(-20001
                             ,'�������� job''� �� ������ ���������� � �����');
    END IF;
    -- �� ������ ������ ����������� par_plsql � begin end;
    INSERT INTO sys_jobs_queue
      (queue_id, job_name, program_code, status)
    VALUES
      (sq_sys_jobs_queue.nextval
      ,gc_job_pref || upper(par_job_name)
      ,'begin ' || par_plsql || ' end;'
      ,'NEW');
    COMMIT;
  END insert_queue;

  /*
    ������ �.
    ������ job'�
    ����������� �� ��������� job'a: JOB_QUEUE_MONITORING
  */
  PROCEDURE run_queue(par_job_name VARCHAR2) IS
    v_is_job_exists NUMBER;
  
    object_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(object_exists, -27477);
  BEGIN
    -- ���������, ���� �� ����� job
    SELECT COUNT(1)
      INTO v_is_job_exists
      FROM dual
     WHERE EXISTS (SELECT jb.job_name FROM dba_scheduler_jobs jb WHERE jb.job_name = par_job_name);
    -- ���� ����������, �������
    IF v_is_job_exists = 1
    THEN
      dbms_scheduler.drop_job(job_name => par_job_name);
    END IF;
    -- ���������
    BEGIN
      dbms_scheduler.create_job(job_name   => par_job_name
                               ,job_type   => 'PLSQL_BLOCK'
                               ,enabled    => TRUE
                               ,auto_drop  => TRUE
                               ,job_action => 'begin
                                                 for vr_rec in (select jq.program_code
                                                                      ,jq.rowid         as rid
                                                                  from sys_jobs_queue jq
                                                                 where jq.job_name = ''' ||
                                              par_job_name || '''
                                                                   and jq.status  != ''FAILED''
                                                                 order by queue_id
                                                               )
                                                 loop
                                                   begin
                                                     execute immediate
                                                       vr_rec.program_code;
                                                     delete from sys_jobs_queue jq
                                                      where jq.rowid = vr_rec.rid;
                                                     commit;
                                                   exception
                                                     when others then
                                                       rollback;
                                                       update sys_jobs_queue jq
                                                          set jq.status = ''FAILED''
                                                        where jq.rowid = vr_rec.rid;
                                                       commit;
                                                       raise;
                                                   end;
                                                 end loop;
                                               end;');
    EXCEPTION
      WHEN object_exists THEN
        raise_application_error(-20001
                               ,'������ ���� ������ � ��������� ' || par_job_name ||
                                ' ��� ����������');
    END;
  END run_queue;

  /*
    ������ �.
    ������� job ��� ���������� �� ��������
  */
  PROCEDURE create_monitoring_job IS
    v_is_job_exists NUMBER;
  BEGIN
    -- ���������, ���� �� ����� job
    SELECT COUNT(1)
      INTO v_is_job_exists
      FROM dual
     WHERE EXISTS
     (SELECT jb.job_name FROM dba_scheduler_jobs jb WHERE jb.job_name = gc_monitoring_job);
    IF v_is_job_exists = 0
    THEN
      dbms_scheduler.create_job(job_name        => gc_monitoring_job
                               ,job_type        => 'PLSQL_BLOCK'
                               ,enabled         => TRUE
                               ,repeat_interval => 'FREQ=HOURLY;BYMINUTE=0,5,10,15,20,25,30,35,40,45,50,55'
                               ,job_action      => 'declare
                                                      v_is_job_exists number;
                                                    begin
                                                      -- ������� ���������� ������, ������� ������ ���� ���������
                                                      for vr_jobs in (select distinct
                                                                             job_name
                                                                        from sys_jobs_queue jq
                                                                       where jq.status  != ''FAILED''
                                                                     )
                                                      loop
                                                        -- ���������, �� �������� �� job � ��������� ������
                                                        select count(*)
                                                          into v_is_job_exists
                                                          from dual
                                                         where exists (select null
                                                                         from dba_scheduler_running_jobs jb
                                                                        where jb.job_name = vr_jobs.job_name);
                                                        -- ���� �� ��������, ���������
                                                        if v_is_job_exists = 0 then
                                                          pkg_scheduler.run_queue(vr_jobs.job_name);
                                                        end if;
                                                      end loop;
                                                    end;');
    ELSE
      raise_application_error(-20001
                             ,'Job � ��������� ' || gc_monitoring_job || ' ��� ����������');
    END IF;
  END create_monitoring_job;
END PKG_SCHEDULER;
/

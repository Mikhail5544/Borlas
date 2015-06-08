CREATE OR REPLACE PACKAGE pkg_dwh IS

  -- vustinov

  PROCEDURE execute_step
  (
    p_dwh_step_id NUMBER
   ,p_work_date   DATE := SYSDATE
  );

  PROCEDURE execute_group
  (
    p_dwh_group_id NUMBER
   ,p_work_date    DATE := SYSDATE
  );

  PROCEDURE execute_by_job;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_dwh IS

  BAD_STEP_EXEPTION         EXCEPTION;
  ALREADY_EXECUTED_EXEPTION EXCEPTION;

  /***************************************************************************/

  PROCEDURE execute_step
  (
    p_dwh_step_id NUMBER
   ,p_work_date   DATE := SYSDATE
  ) IS
    steprow       dwh_step%ROWTYPE;
    res           NUMBER;
    error_message dwh_log.message%TYPE;
    ------------
    PROCEDURE write_log
    (
      p_is_ok NUMBER
     ,p_msg   IN OUT VARCHAR2
    ) IS
    BEGIN
      IF p_is_ok = 0
         AND p_msg IS NULL
      THEN
        p_msg := substr(SQLERRM, 1, 500);
      END IF;
      INSERT INTO dwh_log
        (dwh_log_id, dwh_step_id, dwh_log_date, is_ok, message)
      VALUES
        (sq_dwh_log.nextval, p_dwh_step_id, SYSDATE, p_is_ok, '[execute_step] ' || p_msg);
    
      IF p_is_ok = 0
      THEN
        RAISE BAD_STEP_EXEPTION;
      END IF;
    END;
    ------------
  BEGIN
    -- запись текущего шага
    SELECT * INTO steprow FROM dwh_step WHERE dwh_step_id = p_dwh_step_id;
    -- запустить функцию шага
  
    EXECUTE IMMEDIATE 'begin :res := ' || steprow.code || '(:p_date, :p_errm); end;'
      USING OUT res, IN p_work_date, IN OUT error_message;
  
    IF res <> 0
    THEN
      -- ошибка
      write_log(0, error_message);
    ELSE
      --успех
      write_log(1, steprow.name);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        error_message := NULL;
        write_log(0, error_message);
      END;
  END;

  /***************************************************************************/

  PROCEDURE execute_group
  (
    p_dwh_group_id NUMBER
   ,p_work_date    DATE := SYSDATE
  ) IS
    v_status    CHAR(1);
    v_name      dwh_group.name%TYPE;
    v_work_date DATE;
  BEGIN
    --получить группу
    SELECT status
          ,NAME
          ,nvl(p_work_date /*из параметра!*/, SYSDATE)
      INTO v_status
          ,v_name
          ,v_work_date
      FROM dwh_group
     WHERE dwh_group_id = p_dwh_group_id;
    --проверить, не запущен ли шаг
    IF v_status = 'W'
    THEN
      INSERT INTO dwh_log
        (dwh_log_id, dwh_step_id, dwh_log_date, is_ok, message)
      VALUES
        (sq_dwh_log.nextval
        ,0
        ,SYSDATE
        ,0
        ,'[execute group] ' || p_dwh_group_id || ', "' || v_name || '": already executed!');
      RAISE ALREADY_EXECUTED_EXEPTION;
    END IF;
    --установить статус "запущен"
    UPDATE dwh_group SET status = 'W' WHERE dwh_group_id = p_dwh_group_id;
    --запустить щаги
    FOR group_row IN (SELECT * FROM dwh_step WHERE dwh_group_id = p_dwh_group_id)
    LOOP
      execute_step(group_row.dwh_step_id, v_work_date);
    END LOOP;
    --установить статус "ок"
    UPDATE dwh_group SET status = 'O' WHERE dwh_group_id = p_dwh_group_id;
  EXCEPTION
    WHEN ALREADY_EXECUTED_EXEPTION THEN
      RAISE;
    WHEN OTHERS THEN
      BEGIN
        -- лог, статус "ошибка"
        UPDATE dwh_group SET status = 'E' WHERE dwh_group_id = p_dwh_group_id;
        INSERT INTO dwh_log
          (dwh_log_id, dwh_group_id, dwh_log_date, is_ok, message)
        VALUES
          (sq_dwh_log.nextval
          ,p_dwh_group_id
          ,SYSDATE
          ,0
          ,'[execute_group] ' || p_dwh_group_id || ', "' || v_name || '"');
      END;
  END;

  /***************************************************************************/

  PROCEDURE execute_by_job IS
    v_next_date DATE;
  BEGIN
    FOR group_row IN (SELECT *
                        FROM dwh_group
                       WHERE status <> 'W'
                         AND (next_date <= SYSDATE OR need_execute_now = 1))
    LOOP
      BEGIN
        -- запуск группы
        execute_group(group_row.dwh_group_id, group_row.work_date);
      
        -- вычисление времени следующего запуска
        IF group_row.interval IS NOT NULL
        THEN
          EXECUTE IMMEDIATE 'begin select ' || group_row.interval || ' into :1 from dual; end;'
            USING OUT v_next_date;
        ELSE
          v_next_date := group_row.next_date;
        END IF;
      
        UPDATE dwh_group
           SET next_date        = v_next_date
              ,need_execute_now = 0
              ,work_date        = NULL
         WHERE dwh_group_id = group_row.dwh_group_id;
      
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          DECLARE
            code NUMBER := SQLCODE;
            msg  VARCHAR2(500) := SQLERRM;
          BEGIN
            INSERT INTO dwh_log
              (dwh_log_id, dwh_group_id, dwh_log_date, is_ok, message)
            VALUES
              (sq_dwh_log.nextval
              ,group_row.dwh_group_id
              ,SYSDATE
              ,0
              ,'[execute_by_job] ' || code || ': ' || msg);
          END;
      END;
    END LOOP;
  END;

/* регистрация JOB

declare
  jobno number;
begin
   dbms_job.submit(jobno,
      'pkg_dwh.execute_by_job;',
      sysdate,
      'sysdate + 1/24/60*10'
   );
   commit;
end;

*/

END pkg_dwh;
/

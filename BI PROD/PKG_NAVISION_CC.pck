CREATE OR REPLACE PACKAGE PKG_NAVISION_CC IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 03.08.2011 17:55:47
  -- Purpose : Работа со справочником Центров затрат Navision

  /*
    Байтин А.
    Добавление записи в справочник
  */
  PROCEDURE insert_cc
  (
    par_cc_code        VARCHAR2
   ,par_cc_name        VARCHAR2 DEFAULT NULL
   ,par_open_date      DATE
   ,par_id_1c          NUMBER DEFAULT NULL
   ,par_deleted        NUMBER DEFAULT 0
   ,par_navision_cc_id OUT NUMBER
  );

  /*
    Байтин А.
    Исправление записи в справочнике
  */
  PROCEDURE update_cc
  (
    par_navision_cc_id NUMBER
   ,par_cc_code        VARCHAR2
   ,par_cc_name        VARCHAR2
   ,par_deleted        NUMBER DEFAULT NULL
   ,par_open_date      DATE DEFAULT NULL
  );

  /*
    Байтин А.
    Удаление записи из справочника
  */
  PROCEDURE delete_cc(par_navision_cc_id NUMBER);

  /*
    Байтин А.
    Установка названия ЦЗ
  */
  PROCEDURE set_name
  (
    par_navision_cc_id NUMBER
   ,par_name           VARCHAR2
  );

  /*
    Байтин А.
    Установка даты закрытия ЦЗ
  */
  PROCEDURE set_close_date
  (
    par_navision_cc_id NUMBER
   ,par_close_date     DATE
  );
  /*
    Байтин А.
  
  */
  PROCEDURE sync_with_1c;
END PKG_NAVISION_CC;
/
CREATE OR REPLACE PACKAGE BODY PKG_NAVISION_CC IS
  -- Дата окончания по умолчанию
  gc_default_end_date CONSTANT DATE := to_date('31.12.3000', 'dd.mm.yyyy');
  -- Статус отправки во внешние БД по умолчанию
  gc_default_send_status CONSTANT NUMBER(1) := 0;

  /*
    Байтин А.
    Добавление записи в справочник
  */
  PROCEDURE insert_cc
  (
    par_cc_code        VARCHAR2
   ,par_cc_name        VARCHAR2 DEFAULT NULL
   ,par_open_date      DATE
   ,par_id_1c          NUMBER DEFAULT NULL
   ,par_deleted        NUMBER DEFAULT 0
   ,par_navision_cc_id OUT NUMBER
  ) IS
    v_cnt NUMBER;
  BEGIN
    IF par_cc_code IS NULL
    THEN
      raise_application_error(-20001, 'Код ЦЗ должен быть заполнен');
    END IF;
  
    IF par_open_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'Дата открытия ЦЗ должна быть заполнена');
    END IF;
  
    -- Проверка в справочнике масок
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS
     (SELECT NULL FROM ven_t_navision_cc_pref cp WHERE par_cc_code LIKE cp.nav_prefix || '%');
    IF v_cnt = 0
    THEN
      raise_application_error(-20001
                             ,'Центр затрат с таким кодом запрещен к добавлению, проверьте правильность указанного значения. ' ||
                              'Если значение верное, обратитесь к ответственному лицу для внесения значения в справочник масок ЦЗ.');
    END IF;
  
    SELECT sq_t_navision_cc.nextval INTO par_navision_cc_id FROM dual;
    INSERT INTO ven_t_navision_cc
      (t_navision_cc_id, cc_code, cc_name, open_date, close_date, send_status, id_1c, deleted)
    VALUES
      (par_navision_cc_id
      ,par_cc_code
      ,par_cc_name
      ,par_open_date
      ,gc_default_end_date
      ,gc_default_send_status
      ,par_id_1c
      ,par_deleted);
  END insert_cc;

  /*
    Байтин А.
    Исправление записи в справочнике
  */
  PROCEDURE update_cc
  (
    par_navision_cc_id NUMBER
   ,par_cc_code        VARCHAR2
   ,par_cc_name        VARCHAR2
   ,par_deleted        NUMBER DEFAULT NULL
   ,par_open_date      DATE DEFAULT NULL
  ) IS
    v_cnt NUMBER;
  BEGIN
    -- Проверка в справочнике масок
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS
     (SELECT NULL FROM ven_t_navision_cc_pref cp WHERE par_cc_code LIKE cp.nav_prefix || '%');
    IF v_cnt = 0
    THEN
      raise_application_error(-20001
                             ,'Центр затрат с таким кодом запрещен к добавлению, проверьте правильность указанного значения. ' ||
                              'Если значение верное, обратитесь к ответственному лицу для внесения значения в справочник масок ЦЗ.');
    END IF;
  
    UPDATE ven_t_navision_cc cc
       SET cc.cc_code   = par_cc_code
          ,cc.cc_name   = nvl(par_cc_name, cc.cc_name)
          ,cc.open_date = nvl(par_open_date, cc.open_date)
          ,cc.deleted   = nvl(par_deleted, cc.deleted)
     WHERE cc.t_navision_cc_id = par_navision_cc_id;
  END update_cc;

  /*
    Байтин А.
    Удаление записи из справочника
  */
  PROCEDURE delete_cc(par_navision_cc_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_navision_cc cc WHERE cc.t_navision_cc_id = par_navision_cc_id;
  END delete_cc;
  /*
    Байтин А.
    Установка названия ЦЗ
  */
  PROCEDURE set_name
  (
    par_navision_cc_id NUMBER
   ,par_name           VARCHAR2
  ) IS
  BEGIN
    UPDATE ven_t_navision_cc cc
       SET cc.cc_name = par_name
     WHERE cc.t_navision_cc_id = par_navision_cc_id;
  END set_name;

  /*
    Байтин А.
    Установка даты закрытия ЦЗ
  */
  PROCEDURE set_close_date
  (
    par_navision_cc_id NUMBER
   ,par_close_date     DATE
  ) IS
  BEGIN
    UPDATE ven_t_navision_cc cc
       SET cc.close_date = par_close_date
     WHERE cc.t_navision_cc_id = par_navision_cc_id;
  END set_close_date;

  PROCEDURE sync_with_1c IS
    v_navision_cc_id NUMBER;
    v_error          VARCHAR2(250);
  BEGIN
    FOR vr_rec IN (SELECT c.cost_center_1c_id
                         ,c.cost_center_code
                         ,c.cost_center_name
                         ,c.deleted
                         ,CASE c.close_date
                            WHEN to_date('01.01.0001', 'dd.mm.yyyy') THEN
                             NULL
                            ELSE
                             c.close_date
                          END AS close_date
                         ,c.error_desc
                     FROM insi.gate_cost_center_1c c)
    LOOP
      SAVEPOINT before_changes;
      BEGIN
        BEGIN
          SELECT cc.t_navision_cc_id
            INTO v_navision_cc_id
            FROM t_navision_cc cc
           WHERE cc.id_1c = vr_rec.cost_center_1c_id;
          -- Нашли совпадение, исправляем
          pkg_navision_cc.update_cc(par_navision_cc_id => v_navision_cc_id
                                   ,par_cc_code        => vr_rec.cost_center_code
                                   ,par_cc_name        => vr_rec.cost_center_name
                                   ,par_deleted        => vr_rec.deleted);
          IF vr_rec.close_date IS NULL
          THEN
            pkg_navision_cc.set_close_date(par_navision_cc_id => v_navision_cc_id
                                          ,par_close_date     => gc_default_end_date);
          ELSE
            pkg_navision_cc.set_close_date(par_navision_cc_id => v_navision_cc_id
                                          ,par_close_date     => vr_rec.close_date);
          END IF;
          DELETE FROM insi.gate_cost_center_1c c WHERE c.cost_center_1c_id = vr_rec.cost_center_1c_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- Не нашли совпадение, добавляем
            pkg_navision_cc.insert_cc(par_cc_code        => vr_rec.cost_center_code
                                     ,par_cc_name        => vr_rec.cost_center_name
                                     ,par_open_date      => trunc(SYSDATE, 'dd')
                                     ,par_id_1c          => vr_rec.cost_center_1c_id
                                     ,par_navision_cc_id => v_navision_cc_id);
          
            DELETE FROM insi.gate_cost_center_1c c
             WHERE c.cost_center_1c_id = vr_rec.cost_center_1c_id;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          v_error := substr(regexp_replace(SQLERRM, 'ORA-\d{5}:\s'), 1, 250);
        
          ROLLBACK TO before_changes;
        
          UPDATE insi.gate_cost_center_1c c
             SET c.error_desc = v_error
           WHERE c.cost_center_1c_id = vr_rec.cost_center_1c_id;
      END;
    END LOOP;
  END sync_with_1c;
END PKG_NAVISION_CC;
/

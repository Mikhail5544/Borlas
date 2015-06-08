CREATE OR REPLACE PACKAGE ents_bi IS

  /**
  * Пакет обслуживания технологии разработки для Oracle Discoverer
  * Паект обсуживает как репозитарий по оперативно БД так и по хранилищу
  * @author Alexander Kalabukhov
  * @version 1.01
  */

  /**
  * Схема репозитария Oracle Discoverer, интегрированный с системой
  */
  eul_owner VARCHAR2(30) := 'INS_EUL';
  /**
  * Схема хранилища, интегрированного с системой
  */
  dwh_owner VARCHAR2(30) := 'INS_DWH';

  /**
  * Выдача прав на объекты операционной БД для репозитария Oracle Discoverer
  * @author Alexander Kalabukhov
  * @p_mode Режим: REVOKE - отозвать все права
                   NEW    - права на объекты, которые еще не знанесены в репозитарий
                   ALL    - все права
  */
  PROCEDURE grant_to_eul(p_mode IN VARCHAR2 DEFAULT 'ALL');

  /**
  * Выдача прав на объекты операционной БД для хранилища
  * @author Alexander Kalabukhov
  */
  PROCEDURE grant_to_dwh;

  /**
  * Установить связи с схемой репозитария Oracle Discoverer по операционной БД
  * @author Alexander Kalabukhov
  */
  PROCEDURE link_eul;

  /**
  * Обновить репозитарий Oracle Discoverer по операционной БД
  * @author Alexander Kalabukhov
  */
  PROCEDURE upd_eul;

END;
/
CREATE OR REPLACE PACKAGE BODY ents_bi IS

  PROCEDURE grant_pkg(p_owner IN VARCHAR2) AS
  BEGIN
    EXECUTE IMMEDIATE 'grant execute on ' || ents.v_sch || '.ent to ' || p_owner;
    EXECUTE IMMEDIATE 'grant execute on ' || ents.v_sch || '.acc to ' || p_owner;
    EXECUTE IMMEDIATE 'grant execute on ' || ents.v_sch || '.acc_new to ' || p_owner;
    EXECUTE IMMEDIATE 'grant execute on ' || ents.v_sch || '.doc to ' || p_owner;
  
    FOR v_r IN (SELECT e.schema_name owner
                      ,e.source
                  FROM entity e)
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'grant execute on ' || v_r.owner || '.pkg_' || v_r.source || ' to ' ||
                          p_owner;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END;

  PROCEDURE grant_view_cr AS
  BEGIN
    FOR v_r IN (SELECT *
                  FROM user_objects uo
                 WHERE uo.object_type = 'VIEW'
                   AND substr(uo.object_name, 1, 5) = 'V_CR_')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'grant select on ' || ents.v_sch || '.' || v_r.object_name || ' to ' ||
                          eul_owner;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END;

  PROCEDURE grant_to_eul(p_mode IN VARCHAR2 DEFAULT 'ALL') AS
    v_owner VARCHAR2(30);
  BEGIN
    v_owner := ents.v_sch;
  
    -- Отзыв прав
    FOR v_r IN (SELECT *
                  FROM user_tab_privs utp
                 WHERE utp.grantor = v_owner
                   AND utp.owner = v_owner
                   AND utp.grantee = 'INS_EUL')
    LOOP
      --      dbms_output.put_line('revoke ' || v_r.table_name);
      EXECUTE IMMEDIATE 'revoke ' || v_r.privilege || ' on ' || v_r.owner || '.' || v_r.table_name ||
                        ' from ' || eul_owner;
    END LOOP;
    IF p_mode = 'REVOKE'
    THEN
      RETURN;
    END IF;
  
    IF p_mode = 'NEW'
    THEN
      FOR v_r IN (SELECT e.schema_name owner
                        ,e.source
                    FROM entity e
                   WHERE NOT EXISTS (SELECT 1
                            FROM eul5_objs eo
                           WHERE e.source = eo.obj_developer_key
                             AND e.schema_name = eo.obj_ext_owner
                             AND eo.obj_type = 'SOBJ'))
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'grant select on ' || v_r.owner || '.' || v_r.source || ' to ' ||
                            eul_owner;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
    
    ELSIF p_mode = 'ALL'
    THEN
      FOR v_r IN (SELECT *
                    FROM user_objects uo
                   WHERE uo.object_type = 'PACKAGE'
                     AND substr(uo.object_name, 1, 4) = 'PKG_')
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'grant execute on ' || ents.v_sch || '.' || v_r.object_name || ' to ' ||
                            eul_owner;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
    
      -- Пакеты
      grant_pkg(eul_owner);
    
      -- Представления общесистемных отчетов
      grant_view_cr;
    
      -- Временно для поддержки старых отчето по БСО
      EXECUTE IMMEDIATE 'grant select on ' || ents.v_sch || '.v_document to ' || eul_owner;
      EXECUTE IMMEDIATE 'grant select on ' || ents.v_sch || '.v_doc_templ to ' || eul_owner;
      EXECUTE IMMEDIATE 'grant select on ' || ents.v_sch || '.v_bso_rest to ' || eul_owner;
    END IF;
  END;

  PROCEDURE grant_to_dwh AS
  BEGIN
    -- Представления общесистемных отчетов
    grant_view_cr;
  
    -- Пакеты
    grant_pkg(dwh_owner);
  
    FOR v_r IN (SELECT * FROM user_objects uo WHERE uo.object_type IN ('VIEW', 'TABLES'))
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'grant select on ' || ins.ents.v_sch || '.' || v_r.object_name || ' to ' ||
                          dwh_owner;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  
    FOR v_r IN (SELECT *
                  FROM user_objects uo
                 WHERE uo.object_type IN ('PACKAGE')
                   AND uo.OBJECT_NAME LIKE 'PKG%')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'grant execute on ' || ins.ents.v_sch || '.' || v_r.object_name || ' to ' ||
                          dwh_owner;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    EXECUTE IMMEDIATE 'grant execute on ' || ins.ents.v_sch || '.doc to ' || dwh_owner;
  END;

  PROCEDURE link_eul AS
  BEGIN
    EXECUTE IMMEDIATE 'create or replace synonym eul5_objs for ' || eul_owner || '.eul5_objs';
    EXECUTE IMMEDIATE 'create or replace synonym eul5_expressions for ' || eul_owner ||
                      '.eul5_expressions';
    EXECUTE IMMEDIATE 'create or replace synonym eul5_key_cons for ' || eul_owner || '.eul5_key_cons';
    EXECUTE IMMEDIATE 'create or replace synonym eul5_functions for ' || eul_owner ||
                      '.eul5_functions';
    EXECUTE IMMEDIATE 'create or replace synonym eul5_id_seq for ' || eul_owner || '.eul5_id_seq';
  END;

  PROCEDURE upd_eul IS
    v_exp_name   VARCHAR2(300);
    v_exp_descr  VARCHAR2(300);
    v_it_heading VARCHAR2(300);
  BEGIN
    -- Обновление описаний по сущностям
    UPDATE eul5_objs eo
       SET eo.obj_name        = nvl((SELECT e.name
                                      FROM entity e
                                     WHERE e.source = eo.obj_developer_key
                                       AND e.schema_name = eo.obj_ext_owner)
                                   ,eo.obj_name)
          ,eo.obj_description = nvl((SELECT nvl(e.note, '')
                                      FROM entity e
                                     WHERE e.source = eo.obj_developer_key
                                       AND e.schema_name = eo.obj_ext_owner)
                                   ,eo.obj_description)
     WHERE eo.obj_type = 'SOBJ';
  
    -- Обновление описаний по атрибутам
    FOR v_r IN (SELECT ee.exp_id
                      ,ee.it_obj_id
                      ,ee.exp_developer_key
                  FROM eul5_expressions ee
                 WHERE ee.exp_type = 'CO')
    LOOP
      BEGIN
        SELECT CASE
                 WHEN v_r.exp_developer_key LIKE '%\_URE\_ID' ESCAPE '\' THEN
                  a.name || ' (ИД сущности)'
                 WHEN v_r.exp_developer_key LIKE '%\_URO\_ID' ESCAPE '\' THEN
                  a.name || ' (ИД объекта)'
                 WHEN substr(a.name, 1, 20) = 'ИД объекта сущности ' THEN
                  'ИД ' || substr(a.name, 21)
                 ELSE
                  a.name
               END
              ,a.note
              ,e.name
          INTO v_exp_name
              ,v_exp_descr
              ,v_it_heading
          FROM attr a
         INNER JOIN entity e
            ON e.ent_id = a.ent_id
         INNER JOIN eul5_objs eo
            ON e.source = eo.obj_developer_key
           AND e.schema_name = eo.obj_ext_owner
           AND eo.obj_id = v_r.it_obj_id
           AND eo.obj_type = 'SOBJ'
         WHERE a.col_name = (CASE
                 WHEN v_r.exp_developer_key LIKE '%\_URO\_ID' ESCAPE '\' THEN
                  ents.uref_col_name(v_r.exp_developer_key) || '_URE_ID'
                 ELSE
                  v_r.exp_developer_key
               END);
        IF v_exp_name <> 'Наименование'
        THEN
          v_it_heading := v_exp_name;
        ELSE
          v_exp_name := 'Наим ' || v_it_heading;
        END IF;
      
        UPDATE eul5_expressions ee
           SET ee.exp_name        = v_exp_name
              ,ee.exp_description = v_exp_descr
              ,ee.it_heading      = v_it_heading
         WHERE ee.exp_id = v_r.exp_id;
      EXCEPTION
        WHEN no_data_found THEN
          dbms_output.put_line(v_r.exp_id);
        WHEN OTHERS THEN
          RAISE;
      END;
    
    END LOOP;
    COMMIT;
  
    -- Установка поведения объектов
    /*
        update eul5_expressions e
           set e.it_hidden = 1
         where e.exp_developer_key like '%\_ID' escape
         '\'
           and e.exp_developer_key not like '%\_URE\_ID' escape
         '\'
           and e.exp_developer_key not like '%\_URO\_ID' escape
         '\'
           and e.exp_developer_key not in
               ('ENT_ID', (select o.obj_developer_key || '_ID'
                             from eul5_objs o
                            where o.obj_type = 'SOBJ'
                              and o.obj_id = e.it_obj_id));
    */
    UPDATE eul5_expressions e
       SET e.it_placement = 1
     WHERE e.exp_type = 'CO'
       AND e.exp_developer_key LIKE '%\_ID' ESCAPE '\';
    COMMIT;
  
    -- Установка наименований ссылок
    ents.upd_tmp('uc');
    ents.upd_tmp('ucc');
    COMMIT;
  
    UPDATE eul5_key_cons ekc
       SET ekc.key_name = nvl((SELECT ents.trunc_name(re.name || '-' || e.name || CASE
                                                       WHEN c.constraint_name LIKE 'FKI\_%' ESCAPE '\' THEN
                                                        ''
                                                       ELSE
                                                        ' (' || a.name || ')'
                                                     END
                                                    ,100)
                                FROM tmp_uc c
                               INNER JOIN entity e
                                  ON e.source = c.table_name
                               INNER JOIN tmp_uc rc
                                  ON rc.constraint_name = c.r_constraint_name
                               INNER JOIN entity re
                                  ON re.source = rc.table_name
                               INNER JOIN tmp_ucc cc
                                  ON cc.constraint_name = c.constraint_name
                               INNER JOIN attr a
                                  ON a.source = cc.table_name
                                 AND a.col_name = cc.column_name
                               WHERE c.constraint_type = 'R'
                                 AND c.constraint_name = ekc.key_ext_key
                                 AND (SELECT COUNT(*)
                                        FROM tmp_ucc cc
                                       WHERE cc.constraint_name = c.constraint_name) = 1)
                             ,ekc.key_name)
     WHERE ekc.key_type = 'FK';
  
    UPDATE eul5_key_cons ekc SET ekc.key_description = ekc.key_name;
    COMMIT;
  
    UPDATE eul5_expressions SET it_format_mask = 'DD.MM.YYYY' WHERE it_format_mask = 'DD-MON-RRRR';
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

END;
/

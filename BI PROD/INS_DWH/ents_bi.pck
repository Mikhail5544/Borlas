CREATE OR REPLACE PACKAGE ents_bi IS

  v_dwh_schema VARCHAR2(30) := 'INS_DWH';
  v_eul_schema VARCHAR2(30) := 'INS_EUL';
  v_ins_schema VARCHAR2(30) := 'INS';

  /**
  * Пакет обслуживания DWH
  * @author Alexander Kalabukhov
  * @version 1.00
  */

  /**
  * Создание предствавлений по общесистемным отчетам
  * @author Alexander Kalabukhov
  */
  PROCEDURE create_mview;

  /**
  * Выдача прав для репозитария Oracle Discoverer
  * @author Alexander Kalabukhov
  */
  PROCEDURE grant_to_eul;

END;
/
CREATE OR REPLACE PACKAGE BODY ents_bi IS

  PROCEDURE create_mview AS
  BEGIN
    FOR v_r IN (SELECT utp.table_name
                  FROM user_tab_privs utp
                 WHERE substr(utp.table_name, 1, 5) = 'V_CR_')
    LOOP
      /*
        begin
          execute immediate 'drop materialized view ' || v_r.table_name;
        exception
          when others then
            null; --12003
        end;
      */
      BEGIN
        EXECUTE IMMEDIATE 'create materialized view ' || v_r.table_name || ' build immediate refresh ' ||
                          'complete on demand as select * from ins.' || v_r.table_name;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE <> -12006
          THEN
            RAISE;
          END IF;
      END;
    END LOOP;
  END;

  PROCEDURE grant_to_eul AS
  BEGIN
    FOR v_r IN (SELECT *
                  FROM user_objects uo
                 WHERE uo.object_type = 'MATERIALIZED VIEW'
                   AND substr(uo.object_name, 1, 5) = 'V_CR_')
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'grant select on ' || v_dwh_schema || '.' || v_r.object_name || ' to ' ||
                          v_eul_schema;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    FOR v_r IN (SELECT *
                  FROM user_objects uo
                 WHERE uo.object_type = 'PACKAGE'
                   AND uo.object_name LIKE 'PKG%')
    LOOP
      EXECUTE IMMEDIATE 'grant execute on ' || v_dwh_schema || '.' || v_r.object_name || ' to ' ||
                        v_eul_schema;
    END LOOP;
    --execute immediate 'grant execute on ins_dwh.repository_functions to '|| v_eul_schema;
  END;

END;
/

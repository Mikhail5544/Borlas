CREATE OR REPLACE PACKAGE XX_PKG_LOG IS
  PROCEDURE save_log(p_v IN VARCHAR2);

END;
/
CREATE OR REPLACE PACKAGE BODY XX_PKG_LOG IS
  FUNCTION get_current_user RETURN VARCHAR2 IS
    v_user VARCHAR2(100) := USER;
  BEGIN
    IF USER = ents_bi.eul_owner
    THEN
      v_user := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    END IF;
  
    RETURN v_user;
  END get_current_user;

  PROCEDURE save_log(p_v IN VARCHAR2) IS
    v_user VARCHAR2(512);
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    v_user := get_current_user;
  
    INSERT INTO temp4log (v) VALUES (v_user || ' - ' || p_v);
  
    NULL;
    COMMIT;
  END save_log;
END;
/

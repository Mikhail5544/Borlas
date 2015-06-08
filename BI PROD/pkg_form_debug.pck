CREATE OR REPLACE PACKAGE PKG_FORM_DEBUG IS
  PROCEDURE MESSAGE
  (
    p_id      IN NUMBER
   ,p_message IN VARCHAR2
  );
END;
/
CREATE OR REPLACE PACKAGE BODY PKG_FORM_DEBUG IS

  -- Author  : Marchuk A.
  -- Created : 16.04.2008
  -- Purpose : Утилиты для контроля покрытий в контексте бизнес процессов

  /*
   * Проверка договора на соответствие правилам продукта
   * @author Marchuk A.
   * @param p_c_claim_id      ИД версии договора страхования
  */

  G_DEBUG BOOLEAN DEFAULT FALSE;

  PROCEDURE MESSAGE
  (
    p_id      IN NUMBER
   ,p_message IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    err_text VARCHAR2(2000);
    l_code   NUMBER;
  BEGIN
    IF NOT G_DEBUG
    THEN
      RETURN;
    END IF;
  
    INSERT INTO P_FORM_DEBUG
      (OBJECT_ID, execution_date, operation_type, debug_message)
    VALUES
      (p_id, SYSDATE, 'PKG_FORM_DEBUG', p_message);
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      err_text := SUBSTR(SQLERRM, 1, 200);
      RAISE_APPLICATION_ERROR(-20001, err_text);
  END;
  --
END;
/

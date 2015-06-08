CREATE OR REPLACE PACKAGE PKG_AS_ASSET_DEBUG IS
  PROCEDURE LOG
  (
    p_as_asset_id    IN NUMBER
   ,p_operation_type IN VARCHAR2
   ,p_message        IN VARCHAR2
  );
END;
/
CREATE OR REPLACE PACKAGE BODY PKG_AS_ASSET_DEBUG IS
  PROCEDURE LOG
  (
    p_as_asset_id    IN NUMBER
   ,p_operation_type IN VARCHAR2
   ,p_message        IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO AS_ASSET_DEBUG
      (AS_ASSET_ID, execution_date, operation_type, debug_message)
    VALUES
      (p_as_asset_id, SYSDATE, p_operation_type, p_message);
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
END;
/

CREATE OR REPLACE PROCEDURE sp_ch_test_LOG (ids IN NUMBER, p_message IN VARCHAR2) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

      INSERT INTO ins.tmp$ch_error

        (ids, error_text)

      VALUES

        (ids, p_message);

 

    COMMIT;

 

    EXCEPTION

     WHEN OTHERS THEN

       NULL;

  END;
/


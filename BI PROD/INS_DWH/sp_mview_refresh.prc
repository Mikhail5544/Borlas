CREATE OR REPLACE PROCEDURE sp_mview_refresh IS
BEGIN
  FOR rc IN (SELECT * FROM user_snapshots us WHERE us.NAME LIKE 'MV_CR%')
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'call dbms_mview.refresh(''' || rc.name || ''')';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END sp_mview_refresh;
/

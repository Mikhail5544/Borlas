CREATE OR REPLACE FUNCTION is_test_server RETURN NUMBER IS
  vc_prod_server_name CONSTANT VARCHAR2(255) := 'BPROD01.RENLIFE.COM';
  v_db_name VARCHAR2(255);
BEGIN
  SELECT ora_database_name INTO v_db_name FROM dual;
  IF v_db_name = vc_prod_server_name
  THEN
    RETURN 0;
  ELSE
    RETURN 1;
  END IF;
END is_test_server;
/

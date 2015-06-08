CREATE OR REPLACE PROCEDURE Write_Log(p_pol_id NUMBER, p_pol_num VARCHAR2,mes VARCHAR2, p_acc_id NUMBER) IS
 PRAGMA autonomous_transaction;
 BEGIN
 	  INSERT INTO XX_ACC_MIGR_LOG(policy_id, acc_id, error, pol_num) VALUES(p_pol_id, p_acc_id, mes, p_pol_num);
	  COMMIT;
 END;
/


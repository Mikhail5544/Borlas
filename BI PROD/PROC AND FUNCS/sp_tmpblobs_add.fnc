CREATE OR REPLACE FUNCTION sp_tmpblobs_add RETURN NUMBER IS
  BEGIN
  	   DELETE FROM tmp_blobs;
	   INSERT INTO tmp_blobs(id) VALUES (1);
	   RETURN 1;
  END;
/


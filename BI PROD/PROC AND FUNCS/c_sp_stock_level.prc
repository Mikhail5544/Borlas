CREATE OR REPLACE PROCEDURE C_SP_Stock_Level
(
  ware_id   NUMBER,
  dist_id   NUMBER,
  threshold NUMBER,
  low_stock OUT NUMBER
) IS
  not_serializable EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_serializable, -8177);
  deadlock EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock, -60);
  snapshot_too_old EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_too_old, -1555);
BEGIN
  RETURN;
/*  LOOP
    BEGIN
      SELECT COUNT(DISTINCT s_i_id)
        INTO low_stock
        FROM C_Order_Line,
             C_Stock,
             C_District
       WHERE d_id = dist_id
         AND d_w_id = ware_id
         AND d_id = ol_d_id
         AND d_w_id = ol_w_id
         AND ol_i_id = s_i_id
         AND ol_w_id = s_w_id
         AND s_quantity < threshold
         AND ol_o_id BETWEEN (d_next_o_id - 20) AND (d_next_o_id - 1);
      COMMIT;
      EXIT;
    EXCEPTION
      WHEN not_serializable
           OR deadlock
           OR snapshot_too_old THEN
        ROLLBACK;
    END;
  END LOOP;*/
END;
/


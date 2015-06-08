CREATE OR REPLACE PROCEDURE C_SP_New_Order
(
  ware_id       NUMBER,
  dist_id       NUMBER,
  cust_id       NUMBER,
  ord_ol_cnt    NUMBER,
  ord_all_local NUMBER,
  cust_discount OUT NUMBER,
  cust_last     OUT VARCHAR2,
  cust_credit   OUT VARCHAR2,
  dist_tax      OUT NUMBER,
  ware_tax      OUT NUMBER,
  ord_id        IN OUT NUMBER,
  retry         IN OUT NUMBER,
  cur_date      IN DATE
) AS
 /* dist_rowid ROWID;
  not_serializable EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_serializable, -8177);
  deadlock EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock, -60);
  snapshot_too_old EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_too_old, -1555);
  integrity_viol EXCEPTION;
  PRAGMA EXCEPTION_INIT(integrity_viol, -1);*/
BEGIN
  RETURN;
  /*
  LOOP
    BEGIN
      SELECT C_District.ROWID,
             d_tax,
             d_next_o_id,
             w_tax
        INTO dist_rowid,
             dist_tax,
             ord_id,
             ware_tax
        FROM C_District,
             C_Warehouse
       WHERE d_id = dist_id
         AND d_w_id = w_id
         AND w_id = ware_id;
      UPDATE C_District
         SET d_next_o_id = ord_id + 1
       WHERE ROWID = dist_rowid;
      SELECT c_discount,
             c_last,
             c_credit
        INTO cust_discount,
             cust_last,
             cust_credit
        FROM C_Customer
       WHERE c_id = cust_id
         AND c_d_id = dist_id
         AND c_w_id = ware_id;
      INSERT INTO C_New_Order
      VALUES
        (ord_id,
         dist_id,
         ware_id);
      INSERT INTO C_Order
      VALUES
        (ord_id,
         dist_id,
         ware_id,
         cust_id,
         cur_date,
         11,
         ord_ol_cnt,
         ord_all_local);
      EXIT;
    EXCEPTION
      WHEN not_serializable
           OR deadlock
           OR snapshot_too_old
           OR integrity_viol THEN
        ROLLBACK;
        retry := retry + 1;
    END;
  END LOOP;*/
END;
/


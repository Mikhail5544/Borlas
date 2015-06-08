CREATE OR REPLACE PROCEDURE C_SP_Order_Status_Name
(
  ware_id        NUMBER,
  dist_id        NUMBER,
  cust_id        IN OUT NUMBER,
  bylastname     NUMBER,
  cust_last      IN OUT VARCHAR2,
  cust_first     OUT VARCHAR2,
  cust_middle    OUT VARCHAR2,
  cust_balance   OUT NUMBER,
  ord_id         IN OUT NUMBER,
  ord_entry_d    OUT DATE,
  ord_carrier_id OUT NUMBER,
  ord_ol_cnt     OUT NUMBER
) IS
 /* TYPE rowidarray IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  cust_rowid ROWID;
  ol         BINARY_INTEGER;
  c_num      BINARY_INTEGER;
  row_id     rowidarray;
  not_serializable EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_serializable, -8177);
  deadlock EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock, -60);
  snapshot_too_old EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_too_old, -1555);
  CURSOR c_cur IS
    SELECT ROWID
      FROM C_Customer
     WHERE c_d_id = dist_id
       AND c_w_id = ware_id
       AND c_last = cust_last
     ORDER BY c_w_id,
              c_d_id,
              c_last,
              c_first;
  CURSOR mo_cur IS
    SELECT o_id,
           o_entry_d,
           o_carrier_id,
           o_ol_cnt
      FROM C_Order
     WHERE o_d_id = dist_id
       AND o_w_id = ware_id
       AND o_c_id = cust_id
     ORDER BY o_w_id,
              o_d_id,
              o_c_id,
              o_id DESC;*/
BEGIN
RETURN;
 /* LOOP
    BEGIN
      c_num := 0;
      FOR c_id_rec IN c_cur
      LOOP
        c_num := c_num + 1;
        row_id(c_num) := c_id_rec.ROWID;
      END LOOP;
      cust_rowid := row_id((c_num + 1) / 2);
      SELECT c_id,
             c_balance,
             c_first,
             c_middle,
             c_last
        INTO cust_id,
             cust_balance,
             cust_first,
             cust_middle,
             cust_last
        FROM C_Customer
       WHERE ROWID = cust_rowid;
      OPEN mo_cur;
      FETCH mo_cur
        INTO ord_id, ord_entry_d, ord_carrier_id, ord_ol_cnt;
      CLOSE mo_cur;
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


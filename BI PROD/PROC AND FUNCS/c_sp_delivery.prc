CREATE OR REPLACE PROCEDURE C_SP_Delivery
(
  ware_id    NUMBER,
  carrier_id NUMBER,
  order_1    IN OUT NUMBER,
  order_2    IN OUT NUMBER,
  order_3    IN OUT NUMBER,
  order_4    IN OUT NUMBER,
  order_5    IN OUT NUMBER,
  order_6    IN OUT NUMBER,
  order_7    IN OUT NUMBER,
  order_8    IN OUT NUMBER,
  order_9    IN OUT NUMBER,
  order_10   IN OUT NUMBER,
  retry      IN OUT NUMBER,
  cur_date   IN DATE
) AS
 /* TYPE intarray IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
  order_id   intarray;
  dist_id    INTEGER;
  cust_id    INTEGER;
  amount_sum NUMBER;
  no_rowid   ROWID;
  not_serializable EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_serializable, -8177);
  deadlock EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock, -60);
  snapshot_too_old EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_too_old, -1555);
  CURSOR o_cur IS
    SELECT no_o_id,
           ROWID
      FROM C_New_Order
     WHERE no_w_id = ware_id
       AND no_d_id = dist_id
     ORDER BY no_w_id,
              no_d_id,
              no_o_id;*/
BEGIN
  RETURN;
  /*
  FOR i IN 1 .. 10
  LOOP
    dist_id := i;
    LOOP
      BEGIN
        OPEN o_cur;
        FETCH o_cur
          INTO order_id(i), no_rowid;
        IF (o_cur%NOTFOUND)
        THEN
          CLOSE o_cur;
          COMMIT;
          order_id(i) := 0;
          EXIT;
        END IF;
        CLOSE o_cur;
        DELETE FROM C_New_Order WHERE ROWID = no_rowid;
        UPDATE C_Order
           SET o_carrier_id = carrier_id
         WHERE o_d_id = dist_id
           AND o_w_id = ware_id
           AND o_id = order_id(i);
        SELECT o_c_id
          INTO cust_id
          FROM C_Order
         WHERE o_d_id = dist_id
           AND o_w_id = ware_id
           AND o_id = order_id(i);
        UPDATE C_Order_Line
           SET ol_delivery_d = cur_date
         WHERE ol_d_id = dist_id
           AND ol_w_id = ware_id
           AND ol_o_id = order_id(i);
        SELECT SUM(ol_amount)
          INTO amount_sum
          FROM C_Order_Line
         WHERE ol_d_id = dist_id
           AND ol_w_id = ware_id
           AND ol_o_id = order_id(i);
        UPDATE C_Customer
           SET c_balance      = c_balance + amount_sum,
               c_delivery_cnt = c_delivery_cnt + 1
         WHERE c_id = cust_id
           AND c_d_id = dist_id
           AND c_w_id = ware_id;
        COMMIT;
        EXIT;
      EXCEPTION
        WHEN not_serializable
             OR deadlock
             OR snapshot_too_old THEN
          ROLLBACK;
          retry := retry + 1;
      END;
    END LOOP;
  END LOOP;
  order_1  := order_id(1);
  order_2  := order_id(2);
  order_3  := order_id(3);
  order_4  := order_id(4);
  order_5  := order_id(5);
  order_6  := order_id(6);
  order_7  := order_id(7);
  order_8  := order_id(8);
  order_9  := order_id(9);
  order_10 := order_id(10);*/
END;
/


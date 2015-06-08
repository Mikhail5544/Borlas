CREATE OR REPLACE PROCEDURE C_SP_Payment_ID
(
  ware_id         NUMBER,
  dist_id         NUMBER,
  cust_w_id       NUMBER,
  cust_d_id       NUMBER,
  cust_id         IN OUT NUMBER,
  bylastname      NUMBER,
  hist_amount     NUMBER,
  cust_last       IN OUT VARCHAR2,
  ware_street_1   OUT VARCHAR2,
  ware_street_2   OUT VARCHAR2,
  ware_city       OUT VARCHAR2,
  ware_state      OUT VARCHAR2,
  ware_zip        OUT VARCHAR2,
  dist_street_1   OUT VARCHAR2,
  dist_street_2   OUT VARCHAR2,
  dist_city       OUT VARCHAR2,
  dist_state      OUT VARCHAR2,
  dist_zip        OUT VARCHAR2,
  cust_first      OUT VARCHAR2,
  cust_middle     OUT VARCHAR2,
  cust_street_1   OUT VARCHAR2,
  cust_street_2   OUT VARCHAR2,
  cust_city       OUT VARCHAR2,
  cust_state      OUT VARCHAR2,
  cust_zip        OUT VARCHAR2,
  cust_phone      OUT VARCHAR2,
  cust_since      OUT DATE,
  cust_credit     IN OUT VARCHAR2,
  cust_credit_lim OUT NUMBER,
  cust_discount   OUT NUMBER,
  cust_balance    IN OUT NUMBER,
  cust_data       OUT VARCHAR2,
  retry           IN OUT NUMBER,
  cur_date        IN DATE
) AS
 /* TYPE rowidarray IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  cust_rowid     ROWID;
  ware_rowid     ROWID;
  dist_ytd       NUMBER;
  dist_name      VARCHAR2(11);
  ware_ytd       NUMBER;
  ware_name      VARCHAR2(11);
  c_num          BINARY_INTEGER;
  row_id         rowidarray;
  cust_payments  PLS_INTEGER;
  cust_ytd       NUMBER;
  cust_data_temp VARCHAR2(500);
  not_serializable EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_serializable, -8177);
  deadlock EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock, -60);
  snapshot_too_old EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_too_old, -1555);*/
BEGIN
 RETURN;
 /*
  LOOP
    BEGIN
      SELECT ROWID,
             c_first,
             c_middle,
             c_last,
             c_street_1,
             c_street_2,
             c_city,
             c_state,
             c_zip,
             c_phone,
             c_since,
             c_credit,
             c_credit_lim,
             c_discount,
             c_balance - hist_amount,
             c_payment_cnt,
             c_ytd_payment + hist_amount,
             DECODE(c_credit, 'BC', c_data, ' ')
        INTO cust_rowid,
             cust_first,
             cust_middle,
             cust_last,
             cust_street_1,
             cust_street_2,
             cust_city,
             cust_state,
             cust_zip,
             cust_phone,
             cust_since,
             cust_credit,
             cust_credit_lim,
             cust_discount,
             cust_balance,
             cust_payments,
             cust_ytd,
             cust_data_temp
        FROM C_Customer
       WHERE c_id = cust_id
         AND c_d_id = cust_d_id
         AND c_w_id = cust_w_id;
      cust_payments := cust_payments + 1;
      IF cust_credit = 'BC'
      THEN
        cust_data_temp := substr((to_char(cust_id) || ' ' ||
                                 to_char(cust_d_id) || ' ' ||
                                 to_char(cust_w_id) || ' ' ||
                                 to_char(dist_id) || ' ' ||
                                 to_char(ware_id) || ' ' ||
                                 to_char(hist_amount, '9999.99') || '|') ||
                                 cust_data_temp, 1, 500);
        UPDATE C_Customer
           SET c_balance     = cust_balance,
               c_ytd_payment = cust_ytd,
               c_payment_cnt = cust_payments,
               c_data        = cust_data_temp
         WHERE ROWID = cust_rowid;
        cust_data := substr(cust_data_temp, 1, 200);
      ELSE
        UPDATE C_Customer
           SET c_balance     = cust_balance,
               c_ytd_payment = cust_ytd,
               c_payment_cnt = cust_payments
         WHERE ROWID = cust_rowid;
        cust_data := cust_data_temp;
      END IF;
      SELECT C_District.ROWID,
             d_name,
             d_street_1,
             d_street_2,
             d_city,
             d_state,
             d_zip,
             d_ytd + hist_amount,
             C_Warehouse.ROWID,
             w_name,
             w_street_1,
             w_street_2,
             w_city,
             w_state,
             w_zip,
             w_ytd + hist_amount
        INTO cust_rowid,
             dist_name,
             dist_street_1,
             dist_street_2,
             dist_city,
             dist_state,
             dist_zip,
             dist_ytd,
             ware_rowid,
             ware_name,
             ware_street_1,
             ware_street_2,
             ware_city,
             ware_state,
             ware_zip,
             ware_ytd
        FROM C_District,
             C_Warehouse
       WHERE d_id = dist_id
         AND d_w_id = w_id
         AND w_id = ware_id;
      UPDATE C_District SET d_ytd = dist_ytd WHERE ROWID = cust_rowid;
      UPDATE C_Warehouse SET w_ytd = ware_ytd WHERE ROWID = ware_rowid;
      INSERT INTO C_History
      VALUES
        (cust_id,
         cust_d_id,
         cust_w_id,
         dist_id,
         ware_id,
         cur_date,
         hist_amount,
         ware_name || '    ' || dist_name);
      COMMIT;
      EXIT;
    EXCEPTION
      WHEN not_serializable
           OR deadlock
           OR snapshot_too_old THEN
        ROLLBACK;
        retry := retry + 1;
    END;
  END LOOP;*/
END;
/


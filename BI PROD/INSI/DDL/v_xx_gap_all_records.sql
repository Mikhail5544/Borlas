CREATE OR REPLACE FORCE VIEW V_XX_GAP_ALL_RECORDS AS
SELECT "GATE_PACKAGE_ID","ROW_STATUS","CODE","PAYMENT_ID","PAYMENT_STATUS","PP_NUM","PP_DATE","PP_BNR_DATE","PP_DOC_SUM","PP_REV_AMOUNT","PAYER_INN","PP_FUND","PP_NOTE","PAYER_ACCOUNT","RECEIVER_ACCOUNT","CHANGE_FLAG","PAYER_NAME","PAYER_BANK_NAME","PAYER_BANK_BIC","PAYER_BANK_ACCOUNT","RECEIVER_NAME","RECEIVER_BANK_NAME","RECEIVER_BANK_BIC","RECEIVER_BANK_ACCOUNT"
FROM(
    SELECT "GATE_PACKAGE_ID","ROW_STATUS","CODE","PAYMENT_ID","PAYMENT_STATUS","PP_NUM","PP_DATE","PP_BNR_DATE","PP_DOC_SUM","PP_REV_AMOUNT","PAYER_INN","PP_FUND","PP_NOTE","PAYER_ACCOUNT","RECEIVER_ACCOUNT","CHANGE_FLAG","PAYER_NAME","PAYER_BANK_NAME","PAYER_BANK_BIC","PAYER_BANK_ACCOUNT","RECEIVER_NAME","RECEIVER_BANK_NAME","RECEIVER_BANK_BIC","RECEIVER_BANK_ACCOUNT","RNUM"
        FROM (
              SELECT tab.*, ROW_NUMBER() OVER (PARTITION BY code ORDER BY row_status DESC) rnum
              FROM
                  (
                  SELECT DISTINCT xb.* FROM insi.xx_gap_bad   xb
                  UNION
                  SELECT DISTINCT xg.* FROM insi.xx_gap_good  xg
                  ) tab
             )
        WHERE   rnum = 1
    );


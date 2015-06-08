CREATE OR REPLACE PACKAGE PKG_DSC_REPORT IS

  --сумма оплаты по счету
  FUNCTION Get_Payment_Amount
  (
    p_Payment_ID NUMBER
   ,p_Date       DATE
   ,p_Type       NUMBER
  ) RETURN NUMBER;

END PKG_DSC_REPORT;
/
CREATE OR REPLACE PACKAGE BODY PKG_DSC_REPORT IS

  --сумма оплаты по счету
  FUNCTION Get_Payment_Amount
  (
    p_Payment_ID NUMBER
   ,p_Date       DATE
   ,p_Type       NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(CASE
                     WHEN p_Type = 1 THEN
                      dso.set_off_amount
                     ELSE
                      dso.set_off_child_amount
                   END)
              ,0)
      INTO v_result
      FROM doc_set_off dso
     WHERE dso.set_off_date <= p_Date
       AND dso.parent_doc_id = p_Payment_ID;
    RETURN v_result;
  END;

END PKG_DSC_REPORT;
/

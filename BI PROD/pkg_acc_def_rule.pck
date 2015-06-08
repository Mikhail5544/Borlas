CREATE OR REPLACE PACKAGE Pkg_Acc_Def_Rule IS

  --МОС для определения счета
  FUNCTION Acc_Premium_Set_Off_Acc
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

END Pkg_Acc_Def_Rule;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Acc_Def_Rule IS

  --МОС для определения счета
  FUNCTION Acc_Premium_Set_Off_Acc
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID      NUMBER;
    v_Doc_Templ_Brief VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT dt.brief
        INTO v_Doc_Templ_Brief
        FROM Doc_Set_Off    dso
            ,Ven_Ac_Payment ap
            ,Doc_Templ      dt
       WHERE dso.doc_set_off_id = p_Doc_ID
         AND dso.child_doc_id = ap.payment_id
         AND ap.doc_templ_id = dt.doc_templ_id;
    
      CASE
        WHEN v_Doc_Templ_Brief IN ('A7', 'PD4') THEN
          SELECT a.account_id INTO v_Account_ID FROM ACCOUNT a WHERE a.num = '77.05.01';
        WHEN v_Doc_Templ_Brief IN ('PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC') THEN
          SELECT a.account_id INTO v_Account_ID FROM ACCOUNT a WHERE a.num = '77.08.03';
        WHEN v_doc_templ_brief = 'PAYORDER_SETOFF' THEN
          SELECT a.account_id INTO v_Account_ID FROM ACCOUNT a WHERE a.num = '77.09.03';
        ELSE
          SELECT a.account_id INTO v_Account_ID FROM ACCOUNT a WHERE a.num = '77.00.01';
      END CASE;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := NULL;
    END;
    RETURN v_Account_ID;
  END;

END Pkg_Acc_Def_Rule;
/

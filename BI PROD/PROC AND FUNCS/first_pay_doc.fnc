create or replace function First_pay_doc(p_pol_header_id number) return date
IS
  Result date;
proc_name VARCHAR2(20):='First_pay_doc';
var_date_ret DATE;
BEGIN

SELECT MAX(PA2.due_date) DATE_A7
  INTO VAR_DATE_RET
  FROM VEN_DOC_DOC      D,
       VEN_AC_PAYMENT   AP,
       DOC_SET_OFF      DSO,
       VEN_AC_PAYMENT   PA2,
       AC_PAYMENT_TEMPL ACPT,
       P_POL_HEADER     PH,
       P_POLICY         PP
 WHERE PH.POLICY_HEADER_ID = p_pol_header_id
   AND PP.POL_HEADER_ID = PH.POLICY_HEADER_ID
   AND AP.PAYMENT_NUMBER = 1
   AND D.PARENT_ID = PP.POLICY_ID
   AND ACPT.PAYMENT_TEMPL_ID = PA2.PAYMENT_TEMPL_ID
   AND AP.PAYMENT_ID = D.CHILD_ID
   AND DOC.GET_DOC_STATUS_BRIEF(AP.PAYMENT_ID) = 'PAID'
   AND DSO.PARENT_DOC_ID = AP.PAYMENT_ID
   AND DSO.CHILD_DOC_ID = PA2.PAYMENT_ID
   AND (ACPT.BRIEF = 'A7' OR ACPT.BRIEF = 'PD4' OR ACPT.BRIEF = 'ПП');

  RETURN var_date_ret;
EXCEPTION
  WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении '||proc_name);	
end First_pay_doc;
/


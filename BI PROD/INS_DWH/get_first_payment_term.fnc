CREATE OR REPLACE FUNCTION INS_DWH.get_first_payment_term(par_policy_header_id pls_integer) RETURN VARCHAR2 IS
  Result VARCHAR2(40);
BEGIN
  SELECT pt.description
    INTO RESULT
    FROM ins.p_policy pp,
         ins.t_payment_terms pt
   WHERE pp.pol_header_id = par_policy_header_id
     AND pp.version_num = 1
     AND pt.id = pp.payment_term_id;

  RETURN(Result);
END Get_first_payment_term;


grant execute on INS_DWH.Get_first_payment_term to ins_eul;
/

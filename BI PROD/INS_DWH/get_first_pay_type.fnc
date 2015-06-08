CREATE OR REPLACE FUNCTION Get_first_pay_type(par_policy_header_id PLS_INTEGER) RETURN VARCHAR2 IS
  RESULT VARCHAR2(40);
BEGIN
  SELECT cm.description
    INTO RESULT
    FROM ins.p_policy            pp
        ,ins.t_collection_method cm
   WHERE pp.pol_header_id = par_policy_header_id
     AND pp.version_num = 1
     AND cm.id = pp.collection_method_id;

  RETURN(RESULT);
END Get_first_pay_type;
/

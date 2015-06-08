CREATE OR REPLACE FUNCTION Fn_Get_Ocatd(ADR_ID IN NUMBER) RETURN VARCHAR2 IS

  RESULT VARCHAR2(5);

  res VARCHAR2(5);

  /*v_pr_id     NUMBER;
  
  v_city_id   NUMBER;
  
  v_region_id NUMBER;
  
  v_dist_id   NUMBER;*/

  v_code VARCHAR2(25);

BEGIN

  SELECT adr.code /*adr.province_id, adr.region_id, adr.city_id, adr.district_id*/
  
    INTO v_code /*v_pr_id, v_region_id, v_city_id, v_dist_id*/
  
    FROM ins.CN_ADDRESS adr
  
   WHERE adr.id = ADR_ID;

  IF LENGTH(v_code) = 13
  THEN
    SELECT SUBSTR(kl.ocatd, 1, 5)
      INTO RESULT
      FROM ins.t_kladr kl
     WHERE kl.code = v_code
       AND ROWNUM = 1;
  END IF;

  /*IF v_pr_id IS NOT NULL THEN
    SELECT SUBSTR(pr.ocatd, 1, 5)
      INTO result
      FROM ins.T_PROVINCE pr
     WHERE pr.province_id = v_pr_id
       AND ROWNUM =1;
  END IF;
  dbms_output.put_line('v_pr_id '||v_pr_id);
  dbms_output.put_line('res '||result);
  
  
  IF v_city_id IS NOT NULL THEN
    SELECT SUBSTR(c.ocatd, 1, 5)
      INTO res
      FROM ins.T_CITY c
     WHERE c.city_id = v_city_id
       AND ROWNUM =1;
    IF RES IS NOT NULL THEN result:=RES; END IF;
  END IF;
  dbms_output.put_line('v_city_id '||v_city_id);
  dbms_output.put_line('res '||result);
  
  IF v_region_id IS NOT NULL THEN
    SELECT nvl(SUBSTR(r.ocatd, 1, 5),result)
      INTO result
      FROM ins.T_REGION r
     WHERE r.region_id = v_region_id
       AND ROWNUM = 1;
  END IF;
  dbms_output.put_line('v_region_id '||v_region_id);
  dbms_output.put_line('res '||result);
  
  IF v_dist_id IS NOT NULL THEN
    SELECT SUBSTR(d.ocatd, 1, 5)
      INTO result
      FROM ins.T_DISTRICT d
     WHERE d.district_id = v_dist_id
       AND ROWNUM =1;
  END IF;*/
  dbms_output.put_line('v_code ' || v_code);
  dbms_output.put_line('res ' || RESULT);
  RETURN(RESULT);

END Fn_Get_Ocatd;
/

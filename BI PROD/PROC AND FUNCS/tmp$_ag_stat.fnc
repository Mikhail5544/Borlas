CREATE OR REPLACE FUNCTION tmp$_ag_stat(p_ag_head number,
                                        p_stat_date date, 
                                        p_stat_id number) RETURN DATE IS
  Result DATE;
BEGIN
  FOR r IN
(
SELECT ag_stat_agent_id,
       stat_date,
       lead(ag_stat_agent_id) OVER (ORDER BY num DESC, stat_date DESC) next_stat
  FROM ag_stat_hist
 WHERE ag_contract_header_id = p_ag_head
   AND stat_date< p_stat_date
   ORDER BY num DESC, stat_date DESC
) LOOP
IF p_stat_id<>r.next_stat
THEN Result:=r.stat_date; GOTO end_loop; END IF;
END LOOP;
<<end_loop>>
--dbms_output.put_line(res);
  RETURN(Result);
END tmp$_ag_stat;
/


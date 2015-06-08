create or replace function av_oav_pol_ag_com(p_policy_agent_com_id IN NUMBER)
  return varchar2 IS
  RESULT varchar2(250);
  tmp    number;
BEGIN
  Select case
           when sa.brief in ('Совмест', 'Конс') then
            (select sa3.ag_stat_agent_id
               from ven_ag_stat_agent sa3
              where sa3.brief = 'Конс')
           when sa.brief in ('Менед', 'СтМенед', 'ВедМенед') then
            (select sa4.ag_stat_agent_id
               from ven_ag_stat_agent sa4
              where sa4.brief = 'ФинКонс')
           when sa.brief is null then
            (select sa5.ag_stat_agent_id
               from ven_ag_stat_agent sa5
              where sa5.brief = 'ФинКонс')
           else
            sa.ag_stat_agent_id
         end case
    INTO tmp
    from (select max(sh.num) num, ch.ag_contract_header_id
            from ven_p_policy_agent_com pac,
                 ven_p_policy_agent     pa,
                 ven_ag_contract_header ch,
                 ven_ag_stat_hist       sh
           where pa.p_policy_agent_id = pac.p_policy_agent_id
             and ch.ag_contract_header_id = pa.ag_contract_header_id
             and sh.ag_contract_header_id(+) = ch.ag_contract_header_id
             and (trunc(sh.stat_date, 'DD') <=
                 trunc(to_date(pa.date_start), 'DD'))
             and pac.p_policy_agent_com_id = p_policy_agent_com_id
           group by ch.ag_contract_header_id) v,
         ven_ag_stat_agent sa,
         ven_ag_stat_hist sh2
   where v.ag_contract_header_id = sh2.ag_contract_header_id
     and v.num = sh2.num
     and sa.ag_stat_agent_id(+) = sh2.ag_stat_agent_id
     and rownum = 1;

  if tmp = 1 THEN result := '1 год' ;
/*  ELSE tmp = 2 then result := '2 год' ;
  ELSEif  tmp = 3 then result := '3 год' ;
  else if tmp = 4 then result := '4 год' ;
  else if tmp = 10 then result := 'Единовременая уплата' ;
  else if tmp = 101 then result := '1 год с передачей';
   else if tmp = 102 then result := '2 год с передачей';
    else if tmp = 103 then result := '3 год с передачей';
     else if tmp = 104 then result := '4 год с передачей';*/
   END IF;
     return result;
  END;
/


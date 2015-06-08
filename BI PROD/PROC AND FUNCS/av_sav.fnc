create or replace function av_sav(p_policy_agent_com_id IN NUMBER)
  return varchar2 IS
  tmp    number;
  result varchar2(20);
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

  if tmp = 122 then
    result := 'САВ1';
  elsif tmp = 123 then
    result := 'САВ2';
  elsif tmp = 124 then
    result := 'САВ3';
  elsif tmp = 125 then
    result := 'САВ4';
  end if;

  return (result);
END;
/


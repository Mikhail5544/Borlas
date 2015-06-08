create or replace function av_puv(p_policy_agent_com_id IN NUMBER, p_date date)
  return varchar2 IS
  tmp    number;
  result varchar2(40);
BEGIN
SELECT case
         when ((pt.brief <> 'Единовременно') and
              ((select case
                          when (select count(*)
                                  from p_policy_agent pa2
                                 where pa2.policy_header_id =
                                       ph.policy_header_id
                                   and pa2.date_start < p_date
                                   and not exists
                                 (select '1'
                                          from policy_agent_status s
                                         where s.policy_agent_status_id =
                                               pa2.status_id
                                           and s.brief = 'ERROR')) = 1 then
                           trunc((abs(p_date -
                                      pkg_agent_1.get_agent_start_contr(ph.policy_header_id) + 2) /
                                 365.25),
                                 0) + 1
                          when (select count(*)
                                  from p_policy_agent pa2
                                 where pa2.policy_header_id =
                                       ph.policy_header_id
                                   and pa2.date_start < p_date
                                   and not exists
                                 (select '1'
                                          from policy_agent_status s
                                         where s.policy_agent_status_id =
                                               pa2.status_id
                                           and s.brief = 'ERROR')) > 1 then
                           100
                          else
                           0
                        end case
                   from dual) in (1, 2, 3, 4, 5, 6, 7, 8))) then
          trunc((abs(p_date -
                     pkg_agent_1.get_agent_start_contr(ph.policy_header_id) + 2) /
                365.25),
                0) + 1
         when ((pt.brief <> 'Единовременно') and
              (select case
                         when (select count(*)
                                 from p_policy_agent pa2
                                where pa2.policy_header_id =
                                      ph.policy_header_id
                                  and pa2.date_start < p_date
                                  and not exists
                                (select '1'
                                         from policy_agent_status s
                                        where s.policy_agent_status_id =
                                              pa2.status_id
                                          and s.brief = 'ERROR')) = 1 then
                          trunc((abs(p_date -
                                     pkg_agent_1.get_agent_start_contr(ph.policy_header_id) + 2) /
                                365.25),
                                0) + 1
                         when (select count(*)
                                 from p_policy_agent pa2
                                where pa2.policy_header_id =
                                      ph.policy_header_id
                                  and pa2.date_start < p_date
                                  and not exists
                                (select '1'
                                         from policy_agent_status s
                                        where s.policy_agent_status_id =
                                              pa2.status_id
                                          and s.brief = 'ERROR')) > 1 then
                          100
                         else
                          0
                       end case
                  from dual) not in (1, 2, 3, 4, 5, 6, 7, 8)) then
          trunc((abs(to_date('31122007','ddmmyyyy') -
                     pkg_agent_1.get_agent_start_contr(ph.policy_header_id) + 2) /
                365.25),
                0) + 101
         when (pt.brief = 'Единовременно') then
          10
       end case
  INTO tmp
  FROM P_POLICY_AGENT_COM pac,
       ven_p_policy_agent pa,
       ven_p_pol_header   ph,
       ven_p_policy       p,
       t_payment_terms    pt
 WHERE P_POLICY_AGENT_COM_ID = p_policy_agent_com_id
   and pa.p_policy_agent_id = pac.p_policy_agent_id
   and pa.policy_header_id = ph.policy_header_id
   and ph.policy_id = p.policy_id
   and p.payment_term_id = pt.id;

  if tmp = 1 then
    result := '1 год';
  elsif tmp = 2 then
    result := '2 год';
  elsif tmp = 3 then
    result := '3 год';
  elsif tmp = 4 then
    result := '4 год';
  elsif tmp = 10 then
    result := 'Единовременая уплата';
  elsif tmp = 101 then
    result := '1 год с п';
  elsif tmp = 102 then
    result := '2 год с п';
  elsif tmp = 103 then
    result := '3 год с п';
  elsif tmp = 104 then
    result := '4 год с п';
  end if;

  return (result);
  exception when others then return null;
END;
/


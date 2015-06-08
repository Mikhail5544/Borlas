create or replace function get_leader_id_by_date(p_data_begin      in date,
                                                 p_ag_contr_header in number,
                                                 p_data_pay        in date)
  return number is
  Result number;
begin
  if p_data_pay < p_data_begin then
    select ac_lead.contract_id
      into Result
      from ag_contract ac_ag, ag_contract ac_lead
     where ac_ag.contract_leader_id = ac_lead.ag_contract_id
       and ac_ag.ag_contract_id =
           (SELECT a.ag_contract_id
              FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m,
                           ac.ag_contract_id,
                           ac.date_begin
                      FROM ag_contract ac
                     WHERE trunc(ac.date_begin) <= trunc(p_data_begin)
                       and ac.contract_id = p_ag_contr_header
                     order by ac.date_begin desc) a
             WHERE a.m = a.ag_contract_id
               and rownum = 1);
  else
    select ac_lead.contract_id
      into Result
      from ag_contract ac_ag, ag_contract ac_lead
     where ac_ag.contract_leader_id = ac_lead.ag_contract_id
       and ac_ag.ag_contract_id =
           (SELECT a.ag_contract_id
              FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m,
                           ac.ag_contract_id,
                           ac.date_begin
                      FROM ag_contract ac
                     WHERE trunc(ac.date_begin) <= trunc(p_data_pay)
                       and ac.contract_id = p_ag_contr_header
                     order by ac.date_begin desc) a
             WHERE a.m = a.ag_contract_id
               and rownum = 1);
  end if;
  return(Result);
end get_leader_id_by_date;
/


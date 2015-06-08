create or replace view v_journal_tech_work
as 
select 
    jtw.JOURNAL_TECH_WORK_ID                                            as journal_tech_work_id
  , jtw.WORK_TYPE                                                       as work_type
  , jtw.START_DATE                                                      as start_date
  , jtw.END_DATE                                                        as end_date
  , jtw.AUTHOR_ID                                                       as author_id
  , su.sys_user_name                                                    as sys_user_name
  , jtw.t_subdivisions_id                                               as t_subdivisions_id
  , ts.name                                                             as t_subdivisions_name
  , jtw.t_work_reason_id                                                as t_work_reason_id
  , twr.description                                                     as t_work_reason_description
  , jtw.COMMENTS                                                        as comments
  , jtw.POLICY_HEADER_ID                                                as policy_header_id
  , DSR.NAME                                                            as status_name
  , pp.pol_ser ||'-'||pp.pol_num                                        as pol_num
  , pp.notice_num                                                       as notice_num
  , vi.contact_name                                                     as insurer_name
  , (select dep_.name
      from p_policy_agent_doc pad_
         , document           d_pad_
         , doc_status_ref     dsr_pad_  
         , ag_contract_header ach_ 
         , department         dep_
         , p_pol_header       ph_ 
      where pad_.policy_header_id       = ph_.policy_header_id    
        and pad_.ag_contract_header_id  = ach_.ag_contract_header_id
        and pad_.p_policy_agent_doc_id  = d_pad_.document_id
        and ach_.agency_id              = dep_.department_id
        and d_pad_.doc_status_ref_id    = dsr_pad_.doc_status_ref_id
        and dsr_pad_.brief							 = 'CURRENT'
        and ph_.ids            				 = ph.IDS)                        as AGENCY_NAME
  , ph.ids                                                              as ids
from
    ven_journal_tech_work jtw
  , p_pol_header          ph 
  , sys_user              su 
  , t_subdivisions        ts 
  , t_work_reason         twr
  , doc_status_ref        dsr 
  , p_policy              pp
  , v_pol_issuer          vi
where 
      jtw.policy_header_id   = ph.policy_header_id
  and jtw.author_id          = su.sys_user_id
  and jtw.t_subdivisions_id  = ts.t_subdivisions_id
  and jtw.t_work_reason_id   = twr.t_work_reason_id  
  and jtw.doc_status_ref_id  = dsr.doc_status_ref_id
  and pp.policy_id           = ph.policy_id
  and pp.pol_header_id       = ph.policy_header_id
  and vi.policy_id           = pp.policy_id

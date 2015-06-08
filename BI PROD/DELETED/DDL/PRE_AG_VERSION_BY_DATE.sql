create materialized view INS_DWH.PRE_AG_VERSION_BY_DATE
refresh force on demand
as
select dd.date_id,
       dd.sql_date,
       dd_begin.date_id begin_date_id,
       nvl(dd_break.date_id,-1) end_date_id,
       nvl(dm_ah.ag_contract_header_id,-1) ag_contract_header_id,
       q.ag_contract_id ag_contract_id,
       q.num version_num,
       nvl(dm_agency.agency_id,-1) agency_id,
       q.is_call_center,
       nvl(dm_sh.id,-1) t_sales_channel_id,
       q.guid,
       q.reg_date,
       q.ag_contract_templ_id,
       q.category_id,
       q.class_agent_id,
       q.contract_f_lead_id,
       q.contract_leader_id,
       q.contract_recrut_id,
       q.delegate_id,
       q.initiator_id,
       q.is_comm_holding

  from dm_date dd,
       dm_date dd_begin,
       dm_date dd_break,
       dm_t_sales_channel dm_sh,
       dm_agency dm_agency,
       dm_ag_contract_header dm_ah,

       -- история версий договоров
       (select ac.contract_id,
               ac.ag_contract_id,
               ac.num,
               ac.agency_id,
               nvl(ac.is_call_center,0) is_call_center,
               trunc(ac.date_begin, 'dd') date_begin,
               ac.guid,
               ac.reg_date,
               ac.ag_contract_templ_id,
               ac.category_id,
               ac.class_agent_id,
               ac.contract_f_lead_id,
               ac.contract_leader_id,
               ac.contract_recrut_id,
               ac.delegate_id,
               ac.initiator_id,
               ac.is_comm_holding,
               trunc(nvl((lead(ac.date_begin)
                          over(partition by ac.contract_id order by ac.date_begin, ac.num)) - 1,
                         ac.date_end),
                     'dd') date_end

          from ins.ven_ag_contract ac, ins.ag_contract_header ah1
         where ac.contract_id = ah1.ag_contract_header_id
           and ah1.templ_brief is null) q,
       ins.ag_contract_header ah
 where dd.sql_date between q.date_begin and q.date_end
   and q.contract_id = ah.ag_contract_header_id
   and dd_begin.sql_date = ah.date_begin
   and ah.date_break = dd_break.sql_date (+)
   and q.agency_id = dm_agency.agency_id (+)
   and ah.t_sales_channel_id = dm_sh.id (+)
   and q.contract_id = dm_ah.ag_contract_header_id (+);

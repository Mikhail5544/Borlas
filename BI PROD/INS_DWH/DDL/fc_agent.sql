create materialized view INS_DWH.FC_AGENT
refresh force on demand
as
select
       vv.date_id,
       nvl(vv.ag_contract_header_id,-1) ag_contract_header_id,
       nvl(vv.begin_date_id,-1) begin_date_id,
       nvl(vv.end_date_id,-1) end_date_id,
       nvl(vv.agency_id,-1) agency_id,
       nvl(vv.t_sales_channel_id,-1) t_sales_channel_id,
       nvl(vs.ag_stat_agent_id,-1) ag_stat_agent_id,
       nvl(vs.ag_category_agent_id,nvl(vv.category_id,-1)) ag_category_agent_id,
       nvl(vr.recrut_count,0) recrut_count,
       nvl(vd.status,'неопределено') status,
        case when ((vd.status = 'Расторгнут' or
                    vd.status = 'Закрыт' or
                     vd.status = 'Завершен' or
                     vd.status = 'Отменен' or
                     vd.status = 'Приостановлен')
                     or
                     ((vv.end_date_id <> -1) and (vv.end_date_id is not null)))
                     or to_number(to_char(ah.date_break,'yyyymmdd')) <= vv.date_id
        then 0
        else 1
        end
        is_current,
       nvl(vp.sgp_policy_count,0) sgp_policy_count,
       nvl(vp.sgp_amount,0) sgp_amount,
       nvl(va.ape_amount,0) ape_amount,
       nvl(va.ape_policy_count,0) ape_policy_count,

       -- добавил Иванов 03.03.2010
       nvl(ah.agent_id,-1) contact_id,
       nvl(vv.contract_leader_id,-1) contract_leader_id,
       nvl(vv.contract_f_lead_id,-1) contract_f_lead_id,
       nvl(vv.contract_recrut_id,-1) contract_recrut_id,
       --

       sysdate create_date,
       sysdate modifed_date

  from pre_ag_version_by_date vv
  join ins.ag_contract_header ah on ah.ag_contract_header_id = vv.ag_contract_header_id
  left outer join pre_ag_status_by_date vs on vv.date_id = vs.date_id
                                          and vv.ag_contract_header_id =
                                              vs.ag_contract_header_id
  left outer join pre_ag_doc_status vd on vv.date_id = vd.date_id
                                      and vv.ag_contract_header_id =
                                          vd.ag_contract_header_id
                                      and vv.ag_contract_id =
                                          vd.ag_contract_id
  left outer join pre_ag_recrut vr on vv.ag_contract_header_id =
                                      vr.ag_contract_header_id
                                  and vv.sql_date = vr.date_begin
  left outer join pre_ag_complete_policy vp on vv.ag_contract_header_id =
                                               vp.ag_contract_header_id
                                           and vv.sql_date = vp.accept_date
  left outer join pre_ag_ape_policy va on vv.ag_contract_header_id = va.ag_contract_header_id and

   vv.sql_date = va.trans_date;


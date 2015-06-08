create or replace procedure delete_policy_from_oav(p_ach_num    in varchar2,
                                                   p_pol_num    in varchar2,
                                                   p_date_vedom in date,
                                                   p_pol_ser    in varchar2 default null) as
begin
  if p_pol_ser is not null then
    delete from agent_report_cont arrc
     where arrc.agent_report_cont_id in
           (select arc.agent_report_cont_id
              from agent_report_cont arc
              join p_policy pp on (pp.policy_id = arc.policy_id)
              join agent_report ar on (arc.agent_report_id =
                                      ar.agent_report_id)
              join ven_ag_contract_header ach on (ach.ag_contract_header_id =
                                                 ar.ag_contract_h_id)
              join ag_vedom_av ava on (ava.ag_vedom_av_id =
                                      ar.ag_vedom_av_id)
             where ach.num = p_ach_num
               and pp.pol_ser = p_pol_ser
               and pp.pol_num = p_pol_num
               and ava.date_begin = p_date_vedom);
  else
    delete from agent_report_cont arrc
     where arrc.agent_report_cont_id in
           (select arc.agent_report_cont_id
              from agent_report_cont arc
              join p_policy pp on (pp.policy_id = arc.policy_id)
              join agent_report ar on (arc.agent_report_id =
                                      ar.agent_report_id)
              join ven_ag_contract_header ach on (ach.ag_contract_header_id =
                                                 ar.ag_contract_h_id)
              join ag_vedom_av ava on (ava.ag_vedom_av_id =
                                      ar.ag_vedom_av_id)
             where ach.num = p_ach_num
               and pp.pol_num = p_pol_num
               and ava.date_begin = p_date_vedom);
  end if;
exception
  when others then
    raise_application_error(-20001, 'Delete error' || sqlerrm(sqlcode));
end delete_policy_from_oav;
/


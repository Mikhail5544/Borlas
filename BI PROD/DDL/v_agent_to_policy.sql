CREATE OR REPLACE FORCE VIEW V_AGENT_TO_POLICY AS
SELECT dd.num,
       ph.start_date,
       c.name||' '||c.first_name||' '||c.middle_name agent_name,
       sc.description sch,
       ph.policy_header_id,
       ph.policy_id,
       ap.ag_contract_header_id,
       ap.date_start,
       st.name
FROM p_pol_header ph
     join document dd on dd.document_id = ph.policy_header_id
     join p_policy_agent ap on ap.policy_header_id = ph.policy_header_id
     join ag_contract_header ag on ag.ag_contract_header_id = ap.ag_contract_header_id
     join contact c on c.contact_id = ag.agent_id
     join policy_agent_status st on st.policy_agent_status_id = ap.status_id
     join t_sales_channel sc on sc.id = ph.sales_channel_id
where ap.ag_contract_header_id = pkg_agent_1.get_agent_to_policy(ap.policy_header_id,(select distinct param_value from ins_dwh.rep_param where rep_name = 'agent_pol' and param_name = 'date_start'));


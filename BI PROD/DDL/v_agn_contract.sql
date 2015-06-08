CREATE OR REPLACE VIEW INS.V_AGN_CONTRACT
AS 
SELECT c.obj_name_orig agent_name
      ,h.num
      ,h.date_begin
      ,tct.description leg_pos
      ,nvl(cha.description, ch.description) description
      ,h.t_sales_channel_id sales_channel_id
      ,nvl(cha.brief, ch.brief) sales_channel_brief
      ,cat.category_name
      ,dep.name
      ,a.ag_contract_id
      ,h.ag_contract_header_id
      ,a.category_id
      ,cat.sort_id
      ,(SELECT ent.obj_name('CONTACT', ach1.agent_id)
          FROM ag_contract        ac1
              ,ag_contract_header ach1
         WHERE ac1.contract_id = ach1.ag_contract_header_id
           AND ac1.ag_contract_id = a.contract_leader_id) leader_name
      ,(SELECT ent.obj_name('CONTACT', ach1.agent_id)
          FROM ag_contract        ac1
              ,ag_contract_header ach1
         WHERE ac1.contract_id = ach1.ag_contract_header_id
           AND ac1.ag_contract_id = a.contract_f_lead_id) contract_first_leader
      ,(SELECT ent.obj_name('CONTACT', ach1.agent_id)
          FROM ag_contract        ac1
              ,ag_contract_header ach1
         WHERE ac1.contract_id = ach1.ag_contract_header_id
           AND ac1.ag_contract_id = a.contract_recrut_id) contract_recrut
      ,a.contract_leader_id
      ,a.contract_f_lead_id
      ,a.contract_recrut_id
      ,a.agency_id
      ,a.date_begin ac_date_begin
      ,a.date_end ac_date_end
      ,h.agent_id
      ,a.admin_num
      ,a.personnel_number
      ,act.description contract_type_name
      ,h.with_retention
      ,h.create_docs
      ,h.act_pattern_id
      ,h.report_pattern_id
      ,h.act_num
      ,h.report_num
      ,h.agent_director_name
      ,h.agent_director_doc
      ,h.agent_director
  FROM ven_ag_contract_header h
      ,ag_contract            a
      ,contact                c
      ,t_sales_channel        ch
      ,t_sales_channel        cha
      ,ag_category_agent      cat
      ,department             dep
      ,t_contact_type         tct
      ,t_ag_contract_type     act
 WHERE a.contract_id = h.ag_contract_header_id
   AND h.agent_id = c.contact_id
   AND h.is_new = 1
   AND ch.id = h.t_sales_channel_id
   AND a.ag_sales_chn_id = cha.id
   AND cat.ag_category_agent_id = a.category_id
   AND dep.department_id(+) = a.agency_id
   AND tct.id = a.leg_pos 
   AND a.contract_type_id = act.t_ag_contract_type_id(+) WITH READ ONLY;

grant select on ins.V_AGN_CONTRACT to ins_read;
 

create or replace view ins.v_brokeage_new as
select c.contact_id,
       c.obj_name_orig||' '||d.num contact_name,
       dep.department_id,
       dep.name department_name,
       ot.organisation_tree_id,
       ot.name organisation_name
  from contact c,
       ag_contract_header agh,
       document d,
       ag_contract ac,
       ag_category_agent cat,
       department dep,
       organisation_tree ot,

       employee e,
       employee_hist h

 where agh.is_new = 1
   and ac.agency_id = dep.department_id(+)
   and dep.org_tree_id = ot.organisation_tree_id(+)
   and agh.agent_id = c.contact_id
   and d.document_id = agh.ag_contract_header_id
   and ac.ag_contract_id = agh.last_ver_id
   and ac.category_id = cat.ag_category_agent_id
   and cat.brief in ('MN','DR','DR2','TD','ZD','RD','RM')
   and doc.get_doc_status_name(agh.ag_contract_header_id) = 'Действующий'

   and e.organisation_id = ot.organisation_tree_id
   and h.employee_id = e.employee_id
   and e.contact_id = c.contact_id
   and h.date_hist = (select max(ehlast.date_hist)
                      from employee_hist ehlast
                      where ehlast.employee_id = e.employee_id
                            and ehlast.date_hist <= sysdate
                            and ehlast.is_kicked = 0)
   and nvl(h.is_brokeage,0) = 1
   --and c.obj_name_orig = 'Новоселова Алевтина Юрьевна'
union
select c.contact_id,
       c.obj_name_orig||' '||d.num contact_name,
       dep.department_id,
       dep.name department_name,
       ot.organisation_tree_id,
       ot.name organisation_name
  from contact c,
       ag_contract_header agh,
       t_sales_channel ch,
       document d,
       ag_contract ac,
       department dep,
       organisation_tree ot,

       employee e,
       employee_hist h

 where nvl(agh.is_new,0) = 0
   and ac.agency_id = dep.department_id(+)
   and dep.org_tree_id = ot.organisation_tree_id(+)
   and agh.agent_id = c.contact_id
   and d.document_id = agh.ag_contract_header_id
   and ac.ag_contract_id = agh.last_ver_id
   and doc.get_doc_status_name(agh.ag_contract_header_id) = 'Действующий'
   and agh.t_sales_channel_id = ch.id
   and ch.description in ('Брокерский')

   and e.organisation_id = ot.organisation_tree_id
   and h.employee_id = e.employee_id
   and e.contact_id = c.contact_id
   and h.date_hist = (select max(ehlast.date_hist)
                      from employee_hist ehlast
                      where ehlast.employee_id = e.employee_id
                            and ehlast.date_hist <= sysdate
                            and ehlast.is_kicked = 0)
   and nvl(h.is_brokeage,0) = 1
order by 2 

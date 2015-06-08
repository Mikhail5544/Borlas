create or replace force view v_contact_org_tree as
select c.contact_id, ot.organisation_tree_id
  from contact c, employee e, organisation_tree ot, employee_hist eh
  where c.contact_id = e.contact_id
   and e.organisation_id = ot.organisation_tree_id
   and eh.employee_id = e.employee_id
   and eh.date_hist = (select max(ehlast.date_hist)
                         from employee_hist ehlast
                        where ehlast.employee_id = e.employee_id
                          and ehlast.date_hist <= sysdate
                          and ehlast.is_kicked = 0);

